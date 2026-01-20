#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <strings.h>

#define MAX_APPS 200
#define STR_LEN 256

typedef struct {
    char name[STR_LEN];
    char exec[STR_LEN];
    char icon[STR_LEN];
} App;

// Comparison function for qsort
int compare_apps(const void *a, const void *b) {
    return strcasecmp(((App *)a)->name, ((App *)b)->name);
}

void parse_desktop_file(const char *filename, App *app, int *valid) {
    FILE *fp = fopen(filename, "r");
    if (!fp) return;

    char line[512];
    int in_main = 0;
    *valid = 0;

    while (fgets(line, sizeof(line), fp)) {
        if (line[0] == '[') {
            in_main = (strcmp(line, "[Desktop Entry]\n") == 0);
            continue;
        }
        if (!in_main) continue;

        if (strncmp(line, "Name=", 5) == 0 && app->name[0] == '\0') {
            // Using %.*s tells the compiler exactly how much to safely copy
            snprintf(app->name, STR_LEN, "%.*s", STR_LEN - 1, line + 5);
            app->name[strcspn(app->name, "\r\n")] = 0;
        }
        else if (strncmp(line, "Exec=", 5) == 0 && app->exec[0] == '\0') {
            snprintf(app->exec, STR_LEN, "%.*s", STR_LEN - 1, line + 5);
            app->exec[strcspn(app->exec, "\r\n")] = 0;
            char *p = strchr(app->exec, '%');
            if (p) *p = '\0';
            if (p && p > app->exec && *(p-1) == ' ') *(p-1) = '\0';
        }
        else if (strncmp(line, "Icon=", 5) == 0 && app->icon[0] == '\0') {
            snprintf(app->icon, STR_LEN, "%.*s", STR_LEN - 1, line + 5);
            app->icon[strcspn(app->icon, "\r\n")] = 0;
        }
        else if (strncmp(line, "NoDisplay=", 10) == 0) {
            if (strstr(line, "true")) { *valid = 0; fclose(fp); return; }
        }
    }
    
    if (strlen(app->name) > 0 && strlen(app->exec) > 0) *valid = 1;
    fclose(fp);
}

int main() {
    DIR *dr = opendir("/usr/share/applications");
    if (!dr) return 1;

    App *apps = malloc(sizeof(App) * MAX_APPS);
    int count = 0;
    struct dirent *de;

    while ((de = readdir(dr)) != NULL && count < MAX_APPS) {
        if (strstr(de->d_name, ".desktop")) {
            char path[512];
            snprintf(path, sizeof(path), "/usr/share/applications/%s", de->d_name);
            
            memset(&apps[count], 0, sizeof(App));
            int valid = 0;
            parse_desktop_file(path, &apps[count], &valid);
            if (valid) count++;
        }
    }
    closedir(dr);

    // Sort apps alphabetically by name
    qsort(apps, count, sizeof(App), compare_apps);

    // Output JSON
    printf("[");
    for (int i = 0; i < count; i++) {
        printf("{\"name\":\"%s\",\"exec\":\"%s\",\"icon\":\"%s\"}%s",
               apps[i].name, apps[i].exec, apps[i].icon,
               (i == count - 1) ? "" : ",");
    }
    printf("]\n");

    free(apps);
    return 0;
}