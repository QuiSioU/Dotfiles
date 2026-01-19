#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define MIN_WS 5


void redraw() {
    // 1. Get Active Workspace and the occupied workspaces' IDs
    int active_id = 1;
    FILE *fp1 = popen("hyprctl activeworkspace -j | jq '.id'", "r");
    if (fp1) { fscanf(fp1, "%d", &active_id); pclose(fp1); }

    int occupied[20] = {0};
    int actual_max = 0;
    FILE *fp2 = popen("hyprctl workspaces -j | jq -r '.[].id'", "r");
    if (fp2) {
        int id;
        while (fscanf(fp2, "%d", &id) != EOF) {
            if (id > 0 && id < 20) {
                occupied[id] = 1;
                if (id > actual_max) actual_max = id;
            }
        }
        pclose(fp2);
    }
    int max_ws = (actual_max < MIN_WS) ? MIN_WS : actual_max;

    // 2. Output the Yuck String
    // Outer Eventbox for Scrolling
    printf("(eventbox :onscroll \"if [ '{}' = 'up' ] && [ %d -lt %d ]; then hyprctl dispatch workspace $(( %d + 1 )); elif [ '{}' = 'down' ] && [ %d -gt 1 ]; then hyprctl dispatch workspace $(( %d - 1 )); fi\" ", 
            active_id, max_ws, active_id, active_id, active_id);

    printf("(box :class \"ws-container\" :spacing 10 :space-evenly false");
    
    for (int i = 1; i <= max_ws; i++) {
        if (i == active_id) {
            // THE PILL: An empty box with a specific CSS class
            printf(" (eventbox :onclick \"hyprctl dispatch workspace %d\" (box :class \"ws-pill\"))", i);
        } else {
            // THE DOT: Standard icon for inactive/occupied
            const char *class = occupied[i] ? "ws-occupied" : "ws-free";
            printf(" (eventbox :onclick \"hyprctl dispatch workspace %d\" (label :class \"%s\" :text \"\"))", i, class);
        }
    }
    printf(")) \n");
    fflush(stdout);
}


int main() {
    char *inst = getenv("HYPRLAND_INSTANCE_SIGNATURE");
    char *xdg = getenv("XDG_RUNTIME_DIR");
    if (!inst || !xdg) return 1;

    struct sockaddr_un addr = { .sun_family = AF_UNIX };
    
    // Combine path generation and copying into one safe step
    // sizeof(addr.sun_path) is usually 108. snprintf guarantees null-termination.
    int res = snprintf(addr.sun_path, sizeof(addr.sun_path), "%s/hypr/%s/.socket2.sock", xdg, inst);

    // If the path was too long for the buffer, exit gracefully
    if ((unsigned long)res >= sizeof(addr.sun_path)) {
        fprintf(stderr, "Socket path too long\n");
        return 1;
    }

    int sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
        perror("Socket connect failed");
        return 1;
    }

    // Draw once at startup
    redraw();

    char buffer[1024];
    while (1) {
        ssize_t n = read(sock, buffer, sizeof(buffer) - 1);
        if (n <= 0) break; // Socket closed or error
        buffer[n] = '\0';

        // We only redraw if the event actually affects workspace appearance
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
