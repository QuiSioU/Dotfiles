import definePlugin from "@utils/types";
import { UserStore, GuildMemberStore, IconUtils } from "@webpack/common";

let myChannelId: string | null = null;
let myGuildId: string | null = null;
const knownMembers = new Set<string>();

type TrackedField = { key: string; onTrue: string; onFalse: string };

const trackedFields: TrackedField[] = [
    { key: "selfMute", onTrue: "mute", onFalse: "unmute" },
    { key: "selfDeaf", onTrue: "deafen", onFalse: "undeafen" },
    { key: "mute", onTrue: "server_mute", onFalse: "server_unmute" },
    { key: "deaf", onTrue: "server_deafen", onFalse: "server_undeafen" },
    { key: "selfVideo", onTrue: "camera_on", onFalse: "camera_off" },
    { key: "selfStream", onTrue: "stream_start", onFalse: "stream_stop" },
];

const fieldStates = new Map<string, Map<string, boolean>>();
for (const f of trackedFields) fieldStates.set(f.key, new Map());

function clearFieldStates() {
    for (const m of fieldStates.values()) m.clear();
}

function deleteFieldStates(userId: string) {
    for (const m of fieldStates.values()) m.delete(userId);
}

function emit(type: string, data: Record<string, unknown>) {
    const line = JSON.stringify({ type, ts: Date.now(), ...data });
    console.log("[CallStatusBridge]", line);
    VencordNative.pluginHelpers.CallStatusBridge.emit(line).catch((e: unknown) => {
        console.error("[CallStatusBridge] emit failed", e);
    });
}

function usernameFor(userId: string, guildId?: string | null): string {
    const user = UserStore.getUser(userId);
    if (!user) return userId;

    if (guildId) {
        const nick = GuildMemberStore.getMember(guildId, userId)?.nick;
        if (nick) return nick;
    }

    return user.globalName ?? user.username;
}

function avatarFor(userId: string, guildId?: string | null): string | null {
    const user = UserStore.getUser(userId);
    if (!user) return null;

    if (guildId) {
        const member = GuildMemberStore.getMember(guildId, userId);
        if (member?.avatar) {
            return IconUtils.getGuildMemberAvatarURLSimple({
                userId,
                guildId,
                avatar: member.avatar,
                canAnimate: true
            });
        }
    }

    return IconUtils.getUserAvatarURL(user, true, 128);
}

function checkUserState(state: any, guildId: string | null) {
    const { userId } = state;

    for (const field of trackedFields) {
        const map = fieldStates.get(field.key)!;
        const current = Boolean(state[field.key]);
        const prev = map.get(userId);

        if (prev !== current) {
            map.set(userId, current);
            if (prev !== undefined) {
                emit(current ? field.onTrue : field.onFalse, {
                    userId,
                    username: usernameFor(userId, guildId)
                });
            }
        }
    }
}

export default definePlugin({
    name: "CallStatusBridge",
    description: "Streams your voice call activity to a local socket for external tools.",
    authors: [],
    enabledByDefault: true,

    flux: {
        VOICE_STATE_UPDATES({ voiceStates }) {
            const me = UserStore.getCurrentUser()?.id;

            for (const state of voiceStates) {
                if (state.userId === me) {
                    if (state.channelId !== myChannelId) {
                        if (state.channelId) {
                            emit("you_joined", {
                                channelId: state.channelId,
                                username: usernameFor(me, state.guildId),
                                avatarUrl: avatarFor(me, state.guildId)
                            });
                        } else {
                            emit("you_left", {
                                channelId: myChannelId,
                                username: usernameFor(me, myGuildId)
                            });
                        }
                        knownMembers.clear();
                        clearFieldStates();
                        myChannelId = state.channelId ?? null;
                        myGuildId = state.guildId ?? null;
                    }

                    if (state.channelId) checkUserState(state, state.guildId ?? null);
                    continue;
                }

                if (!myChannelId) continue;

                if (state.channelId === myChannelId && !knownMembers.has(state.userId)) {
                    knownMembers.add(state.userId);
                    emit("join", {
                        userId: state.userId,
                        username: usernameFor(state.userId, myGuildId),
                        avatarUrl: avatarFor(state.userId, myGuildId),
                        channelId: myChannelId
                    });
                } else if (state.channelId !== myChannelId && knownMembers.has(state.userId)) {
                    knownMembers.delete(state.userId);
                    deleteFieldStates(state.userId);
                    emit("leave", {
                        userId: state.userId,
                        username: usernameFor(state.userId, myGuildId),
                        channelId: myChannelId
                    });
                }

                if (state.channelId === myChannelId) checkUserState(state, myGuildId);
            }
        },

        SPEAKING({ userId, speakingFlags, context }) {
            if (context !== "default") return;
            if (!knownMembers.has(userId) && userId !== UserStore.getCurrentUser()?.id) return;

            emit(speakingFlags ? "speaking_start" : "speaking_stop", {
                userId,
                username: usernameFor(userId, myGuildId)
            });
        }
    },

    start() {
        console.log("[CallStatusBridge] started");
    },

    stop() {
        console.log("[CallStatusBridge] stopped");
    }
});
