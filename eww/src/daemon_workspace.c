/* eww/src/daemon_workspace.c */


#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define MIN_WS 5
#define MAX_WS_TRACK 20

// Helper to find a JSON key and return its integer value
int get_json_int(const char *buffer, const char *key) {
    char *ptr = strstr(buffer, key);
    if (ptr) {
        char *colon = strchr(ptr, ':');
        if (colon) return atoi(colon + 1);
    }
    return -1;
}

void redraw() {
    int active_id = 1;
    int occupied[MAX_WS_TRACK] = {0};
    int actual_max = 0;
    char line[1024];

    // 1. Get Active Workspace ID
    FILE *fp1 = popen("hyprctl activeworkspace -j", "r");
    if (fp1) {
        while (fgets(line, sizeof(line), fp1)) {
            int id = get_json_int(line, "\"id\"");
            if (id != -1) { active_id = id; break; }
        }
        pclose(fp1);
    }

    // 2. Get Occupied Workspaces
    FILE *fp2 = popen("hyprctl workspaces -j", "r");
    if (fp2) {
        while (fgets(line, sizeof(line), fp2)) {
            char *ptr = line;
            while ((ptr = strstr(ptr, "\"id\""))) {
                int id = get_json_int(ptr, "\"id\"");
                if (id > 0 && id < MAX_WS_TRACK) {
                    occupied[id] = 1;
                    if (id > actual_max) actual_max = id;
                }
                ptr++; // Move past current match
            }
        }
        pclose(fp2);
    }

    int max_ws = (actual_max < MIN_WS) ? MIN_WS : actual_max;

    printf("[");

    for (int i = 1; i <= max_ws; i++) {
        const char *state;

        if (i == active_id) {
            state = "active";
        } else if (occupied[i]) {
            state = "occupied";
        } else {
            state = "free";
        }

        printf("{\"id\":%d,\"state\":\"%s\"}", i, state);
        if (i < max_ws) printf(",");
    }

    printf("]\n");
    fflush(stdout);
}

int main() {
    // Ensure line-buffered output so Eww receives updates instantly
    setvbuf(stdout, NULL, _IOLBF, 0);

    char *inst = getenv("HYPRLAND_INSTANCE_SIGNATURE");
    char *xdg = getenv("XDG_RUNTIME_DIR");
    if (!inst || !xdg) {
        fprintf(stderr, "Hyprland environment not found\n");
        return 1;
    }

    struct sockaddr_un addr = { .sun_family = AF_UNIX };
    snprintf(addr.sun_path, sizeof(addr.sun_path), "%s/hypr/%s/.socket2.sock", xdg, inst);

    int sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
        perror("Failed to connect to Hyprland socket");
        return 1;
    }

    // Initial draw
    redraw();

    char buffer[1024];
    while (1) {
        ssize_t n = read(sock, buffer, sizeof(buffer) - 1);
        if (n <= 0) break; 
        buffer[n] = '\0';

        // Redraw only on relevant events
        if (strstr(buffer, "workspace>>") || 
            strstr(buffer, "focusedmon>>") || 
            strstr(buffer, "openwindow>>") || 
            strstr(buffer, "closewindow>>") ||
            strstr(buffer, "destroyworkspace>>")) {
            redraw();
        }
    }

    close(sock);
    return 0;
}
