#include <stdio.h>
#include <time.h>

int main() {
    time_t      unix_time = 0;
    struct tm   *info;
    char        day[3], weekday[4], month_num[3], month[4], year[5], time_str[6]; // Include for \0

    time(&unix_time);
    info = localtime(&unix_time);

    if (!info) return 1;
    
    strftime(day,       3, "%d",    info);
    strftime(weekday,   4, "%a",    info);
    strftime(month_num, 3, "%m",    info);
    strftime(month,     4, "%b",    info);
    strftime(year,      5, "%Y",    info);
    strftime(time_str,  6, "%H:%M", info);

    printf(
        "{\"day\": \"%s\", \"weekday\": \"%s\", \"month_num\": \"%s\", \"month\": \"%s\", \"year\": \"%s\", \"time\": \"%s\"}\n",
        day, weekday, month_num, month, year, time_str
    );

    return 0;
}
