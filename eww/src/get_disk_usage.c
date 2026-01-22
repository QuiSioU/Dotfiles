#include <stdio.h>
#include <sys/statvfs.h>

int main() {
    struct statvfs ds;

    // Check statistics for the root directory
    if (statvfs("/", &ds) != 0) {
        printf("{\"error\": \"could not read disk stats\"}\n");
        return 1;
    }

    // Block size * total blocks = total bytes
    double total = (double)ds.f_blocks * ds.f_frsize;
    // Block size * available blocks = free bytes
    double free = (double)ds.f_bavail * ds.f_frsize;
    double used = total - free;

    // Convert to Gigabytes (1024^3)
    double total_gb = total / (1024 * 1024 * 1024);
    double used_gb = used / (1024 * 1024 * 1024);
    
    // Percentage
    double percentage = (used / total) * 100 + 0.5;

    // Output JSON
    // used: GB used, total: Total GB capacity, percentage: % used
    printf(
        "{\"used\": %.2f, \"used_percentage\": %d, \"total\": %.2f}\n", 
        used_gb,
        (int)percentage,
        total_gb
    );

    return 0;
}