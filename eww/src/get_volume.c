/* eww/src/get_volume.c */


#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <alsa/asoundlib.h>
#include <math.h>
#include <alloca.h>


int main() {
    long                    min;                        // Minimum volume value
    long                    max;                        // Maximum volume value
    long                    volume      = 0;            // Current volume value
    int                     unmuted     = 0;            // (1 = unmuted/on, 0 = muted/off)
    int                     percentage  = 0;            // The volume percentage
    snd_mixer_t             *handle;                    // Mixer handler (contains all the info)
    snd_mixer_selem_id_t    *sid;                       // Element Identifier
    snd_mixer_elem_t        *elem;                      // The current element being used (headphones, speaker, ...)
    const char              *card       = "default";    // The soundcard's name
    const char              *selem_name = "Master";     // The name for <elem>
    const char              *icon;                      // The icon representing the volume

    // Initialize the mixer handle
    snd_mixer_open(&handle, 0);
    snd_mixer_attach(handle, card);
    snd_mixer_selem_register(handle, NULL, NULL);
    snd_mixer_load(handle);

    // Find the Master element
    snd_mixer_selem_id_alloca(&sid);
    snd_mixer_selem_id_set_index(sid, 0);
    snd_mixer_selem_id_set_name(sid, selem_name);

    // Get the element (if possible)
    if ((elem = snd_mixer_find_selem(handle, sid)) == NULL) {
        printf("{\"error\": \"Master element not found\"}\n");
        snd_mixer_close(handle);
        return 1;
    }

    snd_mixer_selem_get_playback_volume_range(elem, &min, &max);
    snd_mixer_selem_get_playback_volume(elem, SND_MIXER_SCHN_FRONT_LEFT, &volume);
    snd_mixer_selem_get_playback_switch(elem, SND_MIXER_SCHN_FRONT_LEFT, &unmuted);

    snd_mixer_close(handle);

    // Calculate percentage
    if (max - min > 0) percentage = (int)round(((double)(volume - min) / (max - min)) * 100);

    // Determine Icon
    if      (!unmuted)          icon = "󰝟"; // Muted
    else if (percentage == 0)   icon = "󰕿"; // Volume Off
    else if (percentage <= 60)  icon = "󰖀"; // Volume Normal
    else                        icon = "󰕾"; // Volume High

    printf("{\"volume\": %d, \"muted\": %s, \"icon\": \"%s\"}\n",
        percentage,
        unmuted ? "false" : "true",
        icon
    );

    return 0;
}