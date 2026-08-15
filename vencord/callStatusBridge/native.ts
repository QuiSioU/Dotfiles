import * as net from "net";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import type { IpcMainInvokeEvent } from "electron";

const SOCKET_PATH = path.join(os.tmpdir(), "callstatusbridge.sock");

if (fs.existsSync(SOCKET_PATH)) {
    fs.unlinkSync(SOCKET_PATH);
}

const clients = new Set<net.Socket>();

const server = net.createServer(socket => {
    clients.add(socket);
    socket.on("close", () => clients.delete(socket));
    socket.on("error", () => clients.delete(socket));
});

server.listen(SOCKET_PATH);

export function emit(_event: IpcMainInvokeEvent, line: string) {
    for (const socket of clients) {
        socket.write(line + "\n");
    }
}
