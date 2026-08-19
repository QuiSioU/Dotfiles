import definePlugin from "@utils/types";
import { UserStore, GuildMemberStore, IconUtils, VoiceStateStore } from "@webpack/common";
import { findStoreLazy } from "@webpack";

const SpeakingStore = findStoreLazy("SpeakingStore");

let myChannelId: string | null = null;
let myGuildId: string | null = null;
const knownMembers = new Set<string>();

type StateKey = "micro" | "audio" | "video" | "screen";

const STATE_KEYS: StateKey[] = ["micro", "audio", "video", "screen"];

// Per-user last-known value for each state type, so ongoing updates only emit on change.
const stateMaps = new Map<StateKey, Map<string, boolean>>([
    ["micro", new Map()],
    ["audio", new Map()],
    ["video", new Map()],
    ["screen", new Map()]
]);

function clearStateMaps() {
    for (const m of stateMaps.values()) m.clear();
}

function deleteStateMaps(userId: string) {
    for (const m of stateMaps.values()) m.delete(userId);
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

// Derives the four boolean states from a raw voice state object.
// micro/audio are "active" (true) unless either the self- or server-level flag is set.
function computeState(voiceState: any): Record<StateKey, boolean> {
    return {
        micro: !(voiceState.selfMute || voiceState.mute),
        audio: !(voiceState.selfDeaf || voiceState.deaf),
        video: Boolean(voiceState.selfVideo),
        screen: Boolean(voiceState.selfStream)
    };
}

function emitState(key: StateKey, channelId: string, userId: string, value: boolean) {
    emit(key, { channelId, userId, status: value });
}

function isCurrentlySpeaking(channelId: string, userId: string): boolean {
    try {
        return Boolean(SpeakingStore?.isSpeaking?.(channelId, userId));
    } catch {
        return false;
    }
}

// Records current state for a user and emits messages ONLY for states that are true
// (micro/audio/video/screen/speak). Used for the initial snapshot when someone
// (including you) joins.
function snapshotTrueStates(channelId: string, userId: string, voiceState: any) {
    const computed = computeState(voiceState);

    for (const key of STATE_KEYS) {
        stateMaps.get(key)!.set(userId, computed[key]);
        if (computed[key]) emitState(key, channelId, userId, true);
    }

    if (isCurrentlySpeaking(channelId, userId)) {
        emit("speak", { channelId, userId, status: true });
    }
}

// Compares current state against last-known and emits on any change (true or false).
// Used for ongoing updates after the initial snapshot. Speaking isn't diffed here
// since Discord already fires a dedicated SPEAKING event on every change.
function diffAndEmitStates(channelId: string, userId: string, voiceState: any) {
    const computed = computeState(voiceState);

    for (const key of STATE_KEYS) {
        const map = stateMaps.get(key)!;
        const prev = map.get(userId);
        const current = computed[key];

        if (prev !== current) {
            map.set(userId, current);
            emitState(key, channelId, userId, current);
        }
    }
}

// Emits "joined" for a single user plus a snapshot of their currently-active states.
// Only ever called for the user(s) actually entering the channel at that moment —
// e.g. when someone else joins while you're already in the call, this fires ONLY
// for them, not for you or anyone else already present.
function announceJoin(channelId: string, guildId: string | null, userId: string, voiceState: any) {
    emit("joined", {
        channelId,
        userId,
        username: usernameFor(userId, guildId),
        avatarUrl: avatarFor(userId, guildId)
    });
    snapshotTrueStates(channelId, userId, voiceState);
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
                        if (!state.channelId) {
                            emit("left", { channelId: myChannelId, userId: me });
                        }

                        knownMembers.clear();
                        clearStateMaps();
                        myChannelId = state.channelId ?? null;
                        myGuildId = state.guildId ?? null;

                        if (myChannelId && me) {
                            // Announce yourself first...
                            announceJoin(myChannelId, myGuildId, me, state);

                            // ...then everyone already in the channel.
                            const statesInChannel = VoiceStateStore.getVoiceStatesForChannel(myChannelId) as Record<string, any>;
                            for (const userId in statesInChannel) {
                                if (userId === me) continue;
                                knownMembers.add(userId);
                                announceJoin(myChannelId, myGuildId, userId, statesInChannel[userId]);
                            }
                        }
                        continue;
                    }

                    if (state.channelId) diffAndEmitStates(state.channelId, me, state);
                    continue;
                }

                if (!myChannelId) continue;

                if (state.channelId === myChannelId && !knownMembers.has(state.userId)) {
                    // Someone else joined while you're already in the call:
                    // only their info goes out, nobody else's.
                    knownMembers.add(state.userId);
                    announceJoin(myChannelId, myGuildId, state.userId, state);
                } else if (state.channelId !== myChannelId && knownMembers.has(state.userId)) {
                    knownMembers.delete(state.userId);
                    deleteStateMaps(state.userId);
                    emit("left", { channelId: myChannelId, userId: state.userId });
                } else if (state.channelId === myChannelId) {
                    diffAndEmitStates(myChannelId, state.userId, state);
                }
            }
        },

        SPEAKING({ userId, speakingFlags, context }) {
            if (context !== "default") return;
            if (!myChannelId) return;
            if (userId !== UserStore.getCurrentUser()?.id && !knownMembers.has(userId)) return;

            emit("speak", {
                channelId: myChannelId,
                userId,
                status: Boolean(speakingFlags)
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
