#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include <string.h>

#define SCROLL_DISTANCE 2

int main(int argc, char *argv[]) {
    if (argc < 3) return 1;

    int opt, val = 0;
    while ((opt = getopt(argc, argv, "v:i:o:")) != -1) {
        switch (opt) {
            case 'v':
                val = atoi(optarg);
                break;

            case 'o':
                val += atoi(optarg);
                break;

            case 'i':
                if (!strcmp(optarg, "up")) val += SCROLL_DISTANCE;
                else val -= SCROLL_DISTANCE;
                break;

            default:
                exit(EXIT_FAILURE);
        }
    }


    if (val < 0) val = 0;
    if (val > 100) val = 100;

    char cmd[128];
    // Set hardware quietly
    snprintf(cmd, sizeof(cmd), "brightnessctl set %d%% -q", val);
    system(cmd);

    // Return JSON for EWW
    printf("{\"brightness\": %d}\n", val);
    return 0;
}