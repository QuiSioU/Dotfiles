#define _POSIX_C_SOURCE 200809L
#include <alsa/asoundlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <alloca.h>
#include <getopt.h>
#include <string.h>

#define SCROLL_DISTANCE 2

int main(int argc, char *argv[]) {
    if (argc < 3) return 1;

    int opt;
    long volume = 0;
    while ((opt = getopt(argc, argv, "v:i:o:")) != -1) {
        switch (opt) {
            case 'v':
                volume = atoi(optarg);
                break;

            case 'o':
                volume += atoi(optarg);
                break;

            case 'i':
                if (!strcmp(optarg, "up")) volume += SCROLL_DISTANCE;
                else volume -= SCROLL_DISTANCE;
                break;

            default:
                exit(EXIT_FAILURE);
        }
    }

    if (volume < 0) volume = 0;
    if (volume > 100) volume = 100;

    long min, max;
    snd_mixer_t *handle;
    snd_mixer_elem_t *elem;
    snd_mixer_selem_id_t *sid;

    snd_mixer_open(&handle, 0);
    snd_mixer_attach(handle, "default");
    snd_mixer_selem_register(handle, NULL, NULL);
    snd_mixer_load(handle);
    snd_mixer_selem_id_alloca(&sid);
    snd_mixer_selem_id_set_name(sid, "Master");
    elem = snd_mixer_find_selem(handle, sid);

    if (elem) {
        snd_mixer_selem_get_playback_volume_range(elem, &min, &max);
        long value = (volume * (max - min) / 100) + min;
        snd_mixer_selem_set_playback_volume_all(elem, value);
        snd_mixer_selem_set_playback_switch_all(elem, 1); // Unmute on change
    }
    snd_mixer_close(handle);

    const char *icon; 

    if (volume == 0)        icon = "󰕿"; // Volume Off
    else if (volume <= 60)  icon = "󰖀"; // Volume Normal
    else                    icon = "󰕾"; // Volume High

    // Return JSON for EWW
    // Note: We use the requested volume. The 'get' binary will update the icon later.
    printf("{\"volume\": %ld, \"muted\": false, \"icon\": \"%s\"}\n", volume, icon);
    return 0;
}