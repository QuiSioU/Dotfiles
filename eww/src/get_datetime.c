/* eww/src/get_datetime.c */


#include <stdio.h>
#include <time.h>

int main() {
    time_t      unix_time = 0;
    struct tm   *info;
    char        day[3];
    char        weekday[16];
    char        month_num[3];
    char        month[16];
    char        year[5];
    char        hour[3];
    char        minute[3];
    char        second[3];

    time(&unix_time);
    if ((info = localtime(&unix_time)) == NULL) return 1;
    
    strftime(day,       sizeof(day),        "%d",   info);
    strftime(weekday,   sizeof(weekday),    "%a",   info);
    strftime(month_num, sizeof(month_num),  "%m",   info);
    strftime(month,     sizeof(month),      "%b",   info);
    strftime(year,      sizeof(year),       "%Y",   info);
    strftime(hour,      sizeof(hour),       "%H",   info);
    strftime(minute,    sizeof(minute),     "%M",   info);
    strftime(second,    sizeof(second),     "%S",   info);

    printf(
        "{\"day\": \"%s\", \"weekday\": \"%s\", \"month_num\": \"%s\", \"month\": \"%s\", \"year\": \"%s\", \"hour\": \"%s\", \"minute\": \"%s\", \"second\": \"%s\"}\n",
        day, weekday, month_num, month, year, hour, minute, second
    );

    return 0;
}
