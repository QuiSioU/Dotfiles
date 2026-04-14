/* eww/src/get_brightness.c */


#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *fp = popen("brightnessctl -m", "r");
    if (fp == NULL) {
        printf("{\"brightness\": 0}\n");
        return 1;
    }

    char res[128];
    if (fgets(res, sizeof(res), fp) != NULL) {
        int curr, max;
        char name[32], class[32], perc_str[8];
        
        // Example: intel_backlight,backlight,500,20%,2500
        if (sscanf(res, "%[^,],%[^,],%d,%[^,],%d", name, class, &curr, perc_str, &max) == 5) {
            // Integer rounding: (curr * 100 + max / 2) / max
            int percent = (curr * 100 + (max / 2)) / max;
            printf("{\"brightness\": %d}\n", percent);
        }
    }

    pclose(fp);
    return 0;
}