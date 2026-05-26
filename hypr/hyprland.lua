-- hypr/hyprland.lua


------ LOAD ACTIVE ELYSEAN THEME ------------------------
theme = dofile(os.getenv("HOME") .. "/.config/elysean_themes/active_theme/hypr_quickshell.lua")


------ LOAD ENV VARIABLES (DEFAULT AND/OR CUSTOM) -------
require("default.env")
require("user.env")


------ LOAD VARIABLES (DEFAULT AND/OR CUSTOM) -----------
require("default.variables")
require("user.variables")


------ LOAD DEFAULT CONF")IGURATION -----------------------
require("default.monitors")
require("default.look_and_feel")
require("default.input")
require("default.keybinds")
require("default.windowrules")
require("default.autostart")


----- LOAD USER OVERRIDES -------------------------------
require("user.monitors")
require("user.look_and_feel")
require("user.input")
require("user.keybinds")
require("user.windowrules")
require("user.autostart")
