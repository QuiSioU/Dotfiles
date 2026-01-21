#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <alsa/asoundlib.h>
#include <stdlib.h>
#include <alloca.h>

int main(int argc, char *argv[]) {
    if (argc < 2) return 1;

    long                     volume = atol(argv[1]);
    long                     min;
    long                     max;
    snd_mixer_t             *handle;
    snd_mixer_elem_t        *elem;
    snd_mixer_selem_id_t    *sid;

    snd_mixer_open(&handle, 0);
    snd_mixer_attach(handle, "default");
    snd_mixer_selem_register(handle, NULL, NULL);
    snd_mixer_load(handle);

    snd_mixer_selem_id_alloca(&sid);
    snd_mixer_selem_id_set_name(sid, "Master");
    elem = snd_mixer_find_selem(handle, sid);

    if (elem) {
        snd_mixer_selem_get_playback_volume_range(elem, &min, &max);
        // Convert percentage to absolute value
        long value = (volume * (max - min) / 100) + min;
        snd_mixer_selem_set_playback_volume_all(elem, value);

        printf("Volume set to: %ld%%", volume);
        
        // Ensure it's unmuted when adjusting volume
        snd_mixer_selem_set_playback_switch_all(elem, 1);
    }

    snd_mixer_close(handle);

    return 0;
}