#include <stdio.h>
#include <string.h>

int main() {
    int capacity = 0;
    char status[32];
    const char json_params[] = "{\"capacity\": %d, \"status\": \"%s\"}\n";
    
    FILE *f_cap = fopen("/sys/class/power_supply/BAT1/capacity", "r");
    FILE *f_stat = fopen("/sys/class/power_supply/BAT1/status", "r");

    if (!f_cap || !f_stat) { // Battery missing or some sht
        printf(json_params, 0, "Unknown");
        if (f_cap) fclose(f_cap);
        if (f_stat) fclose(f_stat);
        return 1;
    }

    if (fscanf(f_cap, "%d", &capacity) != 1) capacity = 0;
    if (fscanf(f_stat, "%[^\n]", status) != 1) strcpy(status, "Unknown");

    fclose(f_cap);
    fclose(f_stat);

    printf(json_params, capacity, status);

    return 0;
}
