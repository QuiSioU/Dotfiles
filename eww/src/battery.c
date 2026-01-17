#include <stdio.h>
#include <string.h>

int main() {
    int capacity = 0;
    char status[32];
    
    FILE *f_cap = fopen("/sys/class/power_supply/BAT1/capacity", "r");
    FILE *f_stat = fopen("/sys/class/power_supply/BAT1/status", "r");

    if (f_cap) {
        fscanf(f_cap, "%d", &capacity);
        fclose(f_cap);
    }

    if (f_stat) {
        if (fgets(status, sizeof(status), f_stat)) {
            status[strcspn(status, "\n")] = 0;
        }
        fclose(f_stat);
    }

    printf("{\"capacity\": %d, \"status\": \"%s\"}\n", capacity, status);
    return 0;
}
