-- hypr/default/monitors.lua


----- MONITORS CONFIGURATION -----------------------------

-- See https://wiki.hypr.land/Configuring/Monitors/ for more


-- Monitor resolution, refresh rate and scaling
hl.monitor({
    output   = "",
    mode     = monitor_res,
    position = "auto",
    scale    = monitor_scale,
})


-- unscale XWayland
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})
