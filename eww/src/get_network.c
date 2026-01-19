#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <NetworkManager.h>


/* Helper to uppercase the SSID string in-place */
void format_ssid(char *str) {
    for (int i = 0; str[i]; i++) {
        str[i] = toupper((unsigned char)str[i]);
    }
}


int main() {
    /***********************
    *   Variables needed   *
    ***********************/
    NMClient        *client         = NULL;             // API client, handling everything
    NMDevice        *device         = NULL;             // Contains a network device's information
    NMDevice        *aux_device     = NULL;             // Auxiliary for stuff
    NMDeviceState    state          = 0;                // Contains a network device's state (activated, disconnected, ...)
    const GPtrArray *device_list    = NULL;             // List of available network devices
    GError          *error          = NULL;             // Contains most recent error info (if any)
    NMIPConfig      *ip4_config     = NULL;             // Contains a network device's IPv4 configuration
    char             ssid[256]      = "Disconnected";   // WiFi network's name
    const char      *ip             = "0.0.0.0";        // Local IP address inside network
    const char      *gateway        = "0.0.0.0";        // Gateway's IP address
    const char      *icon           = "󰤮";              // Status icon
    guint            index;                             // Device index in list of devices
    int              mask           = 0;                // CIDR mask
    int             strength        = 0;                // Access point strength


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
    for (index = 0; index < device_list->len; index++) {
        aux_device = g_ptr_array_index(device_list, index);
        state = nm_device_get_state(aux_device);

        const char *interface = nm_device_get_iface(aux_device);
        
        // We don't care about loopback interface
        if (state == NM_DEVICE_STATE_ACTIVATED && strcmp(interface, "lo") != 0) {
            device = aux_device;
            break;
        }
    }


    /****************************************************
    *   Get the info about the active device (if any)   *
    ****************************************************/
    if (device != NULL) {

        // Get IPv4 local address and gateway address
        if ((ip4_config = nm_device_get_ip4_config(device)) != NULL) {
            const GPtrArray *addresses = nm_ip_config_get_addresses(ip4_config);
            if (addresses->len > 0) {
                NMIPAddress *addr = g_ptr_array_index(addresses, 0);
                ip = nm_ip_address_get_address(addr);
                mask = nm_ip_address_get_prefix(addr);
            }
            const char *gw_tmp = nm_ip_config_get_gateway(ip4_config);
            if (gw_tmp) gateway = gw_tmp;
        }

        if (NM_IS_DEVICE_WIFI(device)) {  // 2. Handle WiFi specific details
            NMAccessPoint *ap = nm_device_wifi_get_active_access_point(NM_DEVICE_WIFI(device));
            if (ap) {
                GBytes *ssid_bytes = nm_access_point_get_ssid(ap);
                if (ssid_bytes) {
                    const char *raw_ssid = (const char *)g_bytes_get_data(ssid_bytes, NULL);
                    strncpy(ssid, raw_ssid, sizeof(ssid) - 1);
                    format_ssid(ssid);
                }
                
                // Get status icon based on signal strength
                strength = nm_access_point_get_strength(ap);
                
                if      (strength > 80) icon = "󰤨";
                else if (strength > 50) icon = "󰤥";
                else if (strength > 20) icon = "󰤢";
                else                    icon = "󰤟";
            }
        }
        else if (NM_IS_DEVICE_ETHERNET(device)) {  // 3. Handle Ethernet specific details
            strcpy(ssid, "WIRED CONNECTION");
            icon = "";
            strength = 100;
        }
    }


    /******************************************************
    *   Send final JSON-like string to .yuck via stdout   *
    ******************************************************/
    printf(
        "{\"ssid\": \"%s\", \"icon\": \"%s\", \"ip\": \"%s\", \"gateway\": \"%s\", \"mask\": %d, \"strength\": %d}\n",
        ssid,
        icon,
        ip ? ip : "0.0.0.0", 
        gateway ? gateway : "0.0.0.0",
        mask,
        strength
    );


    /*******************
    *   Close client   *
    *******************/
    g_object_unref(client);

    return 0;
}