/* eww/src/set_workspace.c */


#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <ctype.h>

#define MIN_WSID 5


int get_max_wsid() {
    int max_id = MIN_WSID;

    FILE *fp = popen("hyprctl workspaces -j", "r");
    if (!fp) return max_id;

    char buffer[2048];
    while (fgets(buffer, sizeof(buffer), fp)) {
        // Look for the string '"id":'
        char *found = strstr(buffer, "\"id\":");
        if (found) {
            found += 5;

            while (*found && !isdigit(*found)) found++;
            
            if (isdigit(*found)) {
                int id = atoi(found);
                if (id > max_id) max_id = id;
            }
        }
    }
    pclose(fp);
    return max_id;
}


int main(int argc, char *argv[]) {
    if (argc < 3) return 1;

    int opt;
    int wsid = 0;
    int max_wsid = get_max_wsid();

    while ((opt = getopt(argc, argv, "i:o:")) != -1) {
        switch (opt) {
            case 'o':
                wsid += atoi(optarg);
                break;

            case 'i':
                if (!strcmp(optarg, "up")) wsid++;
                else wsid--;
                break;

            default:
                exit(EXIT_FAILURE);
        }
    }

    if (wsid > max_wsid) wsid = max_wsid;
    else if (wsid < 1) wsid = 1;

    char cmd[64];
    snprintf(cmd, sizeof(cmd), "hyprctl dispatch workspace %d", wsid);
    system(cmd);

    printf("{\"wsid\": %d}\n", wsid);
    return 0;
}