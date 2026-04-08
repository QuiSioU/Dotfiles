#define _DEFAULT_SOURCE
#include <stdio.h>
#include <unistd.h>

typedef struct {
    unsigned long long user, nice, system, idle, iowait, irq, softirq, steal;
} CPUStats;

void get_stats(CPUStats *s) {
    FILE *fp = fopen("/proc/stat", "r");
    if (!fp) return;
    char buffer[256];
    if (fgets(buffer, sizeof(buffer), fp)) {
        sscanf(buffer, "cpu %llu %llu %llu %llu %llu %llu %llu %llu",
               &s->user, &s->nice, &s->system, &s->idle, 
               &s->iowait, &s->irq, &s->softirq, &s->steal);
    }
    fclose(fp);
}

int main() {
    CPUStats s1, s2;

    get_stats(&s1);
    usleep(100000); // 100ms
    get_stats(&s2);

    unsigned long long idle1 = s1.idle + s1.iowait;
    unsigned long long idle2 = s2.idle + s2.iowait;

    unsigned long long total1 = s1.user + s1.nice + s1.system + s1.idle + 
                                s1.iowait + s1.irq + s1.softirq + s1.steal;
    unsigned long long total2 = s2.user + s2.nice + s2.system + s2.idle + 
                                s2.iowait + s2.irq + s2.softirq + s2.steal;

    unsigned long long total_diff = total2 - total1;
    unsigned long long idle_diff = idle2 - idle1;

    if (total_diff == 0) {
        printf("{\"used_percentage\": 0, \"used_decimals\": 0.00}\n");
        return 0;
    }

    double cpu_usage = 100.0 * (total_diff - idle_diff) / total_diff;

    printf("{\"used_percentage\": %.0f, \"used_decimals\": %.2f}\n", cpu_usage, cpu_usage);

    return 0;
}