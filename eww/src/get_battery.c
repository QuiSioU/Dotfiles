/*
    Check in /sys/class/power_supply/ if you have BAT0 or BAT1,
    and adapt code to match your existing files
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void get_battery_info(const char *file_path, long *output) {
    FILE *file;

    if ((file = fopen(file_path, "r")) != NULL) {
        if (fscanf(file, "%ld", output) != 1) *output = 0;
        fclose(file);
    }
}


void get_remaining_time(char *buffer, size_t len, long *charge_now, long *charge_full, long *current_now, const char *status) {
    if (*current_now == 0) {
        snprintf(buffer, len, "Not drawing power");
        return;
    }

    double  hours_left;
    int     h, m;

    if (!strcmp(status, "Charging")) {
        hours_left = (double)(*charge_full - *charge_now) / labs(*current_now);
        
        h = (int)hours_left;
        m = (int)((hours_left - h) * 60);
        snprintf(buffer, len, "%d hours %d minutes to full", h, m);
    }
    else if (!strcmp(status, "Discharging")) {
        hours_left = (double)*charge_now / labs(*current_now);
        
        h = (int)hours_left;
        m = (int)((hours_left - h) * 60);
        snprintf(buffer, len, "%d hours %d minutes left", h, m);
    }
    else {
        strcpy(buffer, "Battery is full or idle");
    }
}


void get_icon(long *percentage, const char *status, char *icon) {
    if (*percentage == 0) strcpy(icon, "--");
    else if (!strcmp(status, "Charging")) strcpy(icon, "󰂄");
    else if (*percentage < 10) strcpy(icon, "󰁺");
    else if (*percentage < 20) strcpy(icon, "󰁻");
    else if (*percentage < 30) strcpy(icon, "󰁼");
    else if (*percentage < 40) strcpy(icon, "󰁽");
    else if (*percentage < 50) strcpy(icon, "󰁾");
    else if (*percentage < 60) strcpy(icon, "󰁿");
    else if (*percentage < 70) strcpy(icon, "󰂀");
    else if (*percentage < 80) strcpy(icon, "󰂁");
    else if (*percentage < 90) strcpy(icon, "󰂂");
    else strcpy(icon, "󰁹");
}


int main() {
    long    capacity = 0;           // Battery percentage
    long    charge_now = 0;         // Battery remaining charge value
    long    charge_full = 0;        // Battery maximum charge value
    long    current_now = 0;        // Battery maximum charge value
    char    status[32] = "Unknown"; // Battery status
    char    time_left[32];          // Charge/discharge time left
    char    icon[32];               // Icon based on status and percentage
    FILE    *status_file;           // Charging status file
    

    /***************************************
    *   Get remaining battery percentage   *
    ***************************************/
    get_battery_info("/sys/class/power_supply/BAT1/capacity", &capacity);


    /********************************************
    *   Get remaining actual int charge value   *
    ********************************************/
    get_battery_info("/sys/class/power_supply/BAT1/charge_now", &charge_now);


    /***********************************
    *   Get maximum int charge value   *
    ***********************************/
    get_battery_info("/sys/class/power_supply/BAT1/charge_full", &charge_full);


    /**************************************
    *   Get actual charge/discharge rate  *
    **************************************/
    get_battery_info("/sys/class/power_supply/BAT1/current_now", &current_now);


    /**********************************************************
    *   Get battery status: "Charging", "Not charging", ...   *
    **********************************************************/
    if ((status_file = fopen("/sys/class/power_supply/BAT1/status", "r")) != NULL) {
        if (fgets(status, sizeof(status), status_file)) {
            status[strcspn(status, "\n")] = 0;
        }
        fclose(status_file);
    }


    /*****************************************
    *   Get remaining charge/discharge time  *
    *****************************************/
    get_remaining_time(time_left, sizeof(time_left), &charge_now, &charge_full, &current_now, status);


    /***********************
    *   Get battery icon   *
    ***********************/
    get_icon(&capacity, status, icon);


    /******************************************************
    *   Send final JSON-like string to .yuck via stdout   *
    ******************************************************/
    printf("{\"capacity\": %ld, \"status\": \"%s\", \"icon\": \"%s\", \"time_left\": \"%s\"}\n",
        capacity,
        status,
        icon,
        time_left
    );
    return 0;
}
