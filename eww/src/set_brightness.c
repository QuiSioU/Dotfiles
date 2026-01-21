#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc < 2) return 1;
    int val = atoi(argv[1]);
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