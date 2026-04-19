/* eww/src/get_battery.c */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>


#define POWER_SUPPLY_DIR     "/sys/class/power_supply"
#define POWER_SUPPLY_DIR_LEN 24
#define MAX_NAME_LEN         255
#define MAX_SUFFIX_LEN       13
#define MAX_PATH_LEN         (POWER_SUPPLY_DIR_LEN + 1 + MAX_NAME_LEN + MAX_SUFFIX_LEN + 1)
 
#define STATUS_LEN 32


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
        snprintf(buffer, len, "Battery is full or idle");
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


void print_json(long capacity, const char *status, const char *icon, const char *time_left) {
    printf("{\"capacity\": %ld, \"status\": \"%s\", \"icon\": \"%s\", \"time_left\": \"%s\", \"class\": \"BAT%ld\"}\n",
        capacity,
        status,
        icon,
        time_left,
        capacity / 10
    );
}


int main() {
    long    capacity                    = 0;            // Battery percentage
    long    charge_now                  = 0;            // Battery remaining charge value
    long    charge_full                 = 0;            // Battery maximum charge value
    long    current_now                 = 0;            // Battery maximum charge value
    long    tmp                         = 0;            // temporal variable for retrieving info
    int     found                       = 0;            // Whether at least 1 battery was found
    char    status[32]                  = "Unknown";    // Battery status
    char    last_status[32]             = "Unknown";    // Status of the last battery checked
    char    path_buffer[MAX_PATH_LEN];                  // Buffer for file paths
    char    time_left[32];                              // Charge/discharge time left
    char    icon[32];                                   // Icon based on status and percentage
    FILE    *status_file;                               // Charging status file


    /* Scan power supply dir and aggregate all BAT* entries */
    DIR *dir;
 
    if ((dir = opendir(POWER_SUPPLY_DIR)) == NULL) {
        print_json(0L, "No battery", "--", "Cannot open power supply directory");
        return 1;
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        if (strncmp(entry->d_name, "BAT", 3) != 0) continue;

        const char *battery_dir = entry->d_name;
        found++;

        /* Get remaining actual int charge value */
        snprintf(path_buffer, MAX_PATH_LEN, "%s/%s/charge_now", POWER_SUPPLY_DIR, battery_dir);
        get_battery_info(path_buffer, &tmp);
        charge_now += tmp;

        /* Get maximum int charge value */
        snprintf(path_buffer, MAX_PATH_LEN, "%s/%s/charge_full", POWER_SUPPLY_DIR, battery_dir);
        get_battery_info(path_buffer, &tmp);
        charge_full += tmp;

        /* Get actual charge/discharge rate */
        snprintf(path_buffer, MAX_PATH_LEN, "%s/%s/current_now", POWER_SUPPLY_DIR, battery_dir);
        get_battery_info(path_buffer, &tmp);
        current_now += tmp;

        /* Get battery status: "Charging", "Not charging", ... */
        snprintf(path_buffer, MAX_PATH_LEN, "%s/%s/status", POWER_SUPPLY_DIR, battery_dir);
        if ((status_file = fopen(path_buffer, "r")) != NULL) {
            if (fgets(last_status, sizeof(last_status), status_file)) {
                last_status[strcspn(last_status, "\n")] = 0;
                if (!strcmp(last_status, "Charging") || !strcmp(last_status, "Discharging")) {
					snprintf(status, STATUS_LEN, "%s", last_status);
                }
            }
            fclose(status_file);
        }
    }

    closedir(dir);

    if (!found) {
        print_json(0L, "No battery", "--", "No battery found");
        return 1;
    }

    /* Fall back to last seen status if none was Charging/Discharging */
    if (!strcmp(status, "Unknown"))
		snprintf(status, STATUS_LEN, "%s", last_status);

    /* Derive remaining battery percentage from aggregated charge values */
    if (charge_full > 0)
        capacity = (charge_now * 100) / charge_full;
    
    /* Get remaining charge/discharge time */
    get_remaining_time(time_left, sizeof(time_left), &charge_now, &charge_full, &current_now, status);


    /* Get battery icon */
    get_icon(&capacity, status, icon);


    /* Send final JSON-like string to stdout */
    print_json(capacity, status, icon, time_left);
    return 0;
}
