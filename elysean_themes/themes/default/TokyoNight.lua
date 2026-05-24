-- elysean_themes/default/TokyoNight.lua


return {

    -- Colors
    color = {

        -- Backgrounds
        BG_DARK         = "rgba(16161eff)",   -- Deepest bg (titlebars, borders)
        BG              = "rgba(1a1b26ff)",   -- Main background
        BG_HIGHLIGHT    = "rgba(292e42ff)",   -- Raised surfaces, hover
        TERMINAL_BLACK  = "rgba(414868ff)",   -- Input fields, popups
        SURFACE         = "rgba(1e2030ff)",   -- Slightly lifted from BG, below BG_HIGHLIGHT
        SURFACE_OVERLAY = "rgba(ffffff0f)",   -- White at 6% opacity, universal hover tint

        -- Foregrounds
        FG              = "rgba(c0caf5ff)",   -- Primary text
        FG_DARK         = "rgba(a9b1d6ff)",   -- Secondary / dimmed text
        FG_DISABLED     = "rgba(545c7eff)",   -- Truly disabled text
        DARK5           = "rgba(737aa2ff)",   -- Disabled / placeholder text
        DARK3           = "rgba(545c7eff)",   -- Line numbers, gutters

        -- Accents
        ACCENT          = "rgba(7aa2f7ff)",   -- Primary accent (focused borders, links)
        ACCENT_BRIGHT   = "rgba(7dcfffff)",   -- Bright accent (active elements)
        ACCENT_MUTED    = "rgba(a8c4ffff)",   -- Desaturated accent (active text, subtle on)
        ACCENT_DIM      = "rgba(394b70ff)",   -- Dark accent (tinted surfaces, pressed states)
        ACCENT_SURFACE  = "rgba(394b70ff)",   -- Subtle accent (backgrounds, tints)

        -- Semantic
        SUCCESS         = "rgba(9ece6aff)",   -- Success
        SUCCESS_MUTED   = "rgba(c4e38fff)",   -- Soft green (active text on dark)
        WARNING         = "rgba(e0af68ff)",   -- Warning
        WARNING_MUTED   = "rgba(eecb96ff)",   -- Soft yellow (warning text on dark)
        ERROR           = "rgba(f7768eff)",   -- Error
        ERROR_MUTED     = "rgba(fab8c4ff)",   -- Soft red (error text on dark)
        INFO            = "rgba(73dacaff)",   -- Info / teal

        -- Extras
        SHADOW          = "rgba(16161eee)",   -- Subtle shadow
        SECONDARY       = "rgba(bb9af7ff)",   -- Purple (notifications, tags)
        URGENT          = "rgba(ff9e64ff)",   -- Orange (urgent, badges)
    }
}
