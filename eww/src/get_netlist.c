#include <stdio.h>
#include <NetworkManager.h>


int main() {
    NMClient        *client;
    GError          *error          = NULL; // Contains most recent error info (if any)
    NMDevice        *device         = NULL;
    NMDevice        *aux_device     = NULL;
    NMDeviceState    state          = 0;    // Contains a network device's state (activated, disconnected, ...)
    const GPtrArray *device_list    = NULL;
    const GPtrArray *aps            = NULL;
    NMAccessPoint   *active_ap      = NULL;


    /***********************
    *   Initialize client  *
    ***********************/
    if ((client = nm_client_new(NULL, &error)) == NULL) {
        printf("{\"error\": \"Network Manager not running\"}\n");
        return 1;
    }


    /*********************************
    *   Get list of network devices  *
    *********************************/
    device_list = nm_client_get_devices(client);


    /************************************
    *   Get active (connected) device   *
    ************************************/
    for (guint i = 0; i < device_list->len; i++) {
        aux_device = g_ptr_array_index(device_list, i);
        state = nm_device_get_state(aux_device);

        const char *interface = nm_device_get_iface(aux_device);
        
        // We don't care about loopback interface
        if (state == NM_DEVICE_STATE_ACTIVATED && strcmp(interface, "lo") != 0) {
            device = aux_device;
            break;
        }
    }


    /**********************************************
    *   Create JSON array of available networks   *
    **********************************************/
    int first = 1; // Track if we are printing the first valid item
    printf("[");

    if (device && NM_IS_DEVICE_WIFI(device)) {
        aps = nm_device_wifi_get_access_points(NM_DEVICE_WIFI(device));
        active_ap = nm_device_wifi_get_active_access_point(NM_DEVICE_WIFI(device));

        for (guint i = 0; i < aps->len; i++) {
            NMAccessPoint *ap = g_ptr_array_index(aps, i);
            GBytes *ssid_bytes = nm_access_point_get_ssid(ap);
            if (!ssid_bytes) continue;

            const char *ssid = (const char *)g_bytes_get_data(ssid_bytes, NULL);
            if (strlen(ssid) == 0) continue; // Skip hidden/empty SSIDs

            int in_use = (ap == active_ap);
            
            // For now, let's assume if it's in use, it's 'auto'. 
            // Real 'autoconnect' logic requires checking NMConnection profiles.
            const char *autoconnect = in_use ? "true" : "false";

            if (!first) printf(", ");
            printf(
                "{\"ssid\": \"%s\", \"in_use\": %s, \"autoconnect\": %s}",
                ssid,
                in_use ? "true" : "false",
                autoconnect
            );
            first = 0;
        }
    }
    printf("]\n");

    g_object_unref(client);

    fflush(stdout);
    
    return 0;
}