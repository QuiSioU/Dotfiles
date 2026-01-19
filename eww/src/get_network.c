#include <stdio.h>
// #include <libnm/NetworkManager.h>

int main() {
    char    *ssid = "Disconnected";
    char    *icon = "⚠";



    printf(
        "{\"ssid\": \"%s\", \"icon\": \"%s\"}\n",
        ssid,
        icon
    );

    return 0;
}