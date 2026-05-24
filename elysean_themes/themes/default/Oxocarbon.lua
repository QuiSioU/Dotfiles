-- elysean_themes/default/Oxocarbon.lua


return {

    -- Colors
    color = {

        -- Backgrounds
        BG              = "rgba(161616ff)",   -- Main background
        BG_DARK         = "rgba(0f0f0fff)",   -- Deepest bg (titlebars, borders)
        BG_HIGHLIGHT    = "rgba(262626ff)",   -- Raised surfaces, hover
        TERMINAL_BLACK  = "rgba(393939ff)",   -- Input fields, popups

        -- Foregrounds
        FG              = "rgba(f2f4f8ff)",   -- Primary text
        FG_DARK         = "rgba(dde1e7ff)",   -- Secondary / dimmed text
        DARK5           = "rgba(6f6f6fff)",   -- Disabled / placeholder text
        DARK3           = "rgba(525252ff)",   -- Line numbers, gutters
        FG_DISABLED     = "rgba(525252ff)",   -- Truly disabled text (same as DARK3, explicit role)

        -- Accents
        ACCENT          = "rgba(78a9ffff)",   -- Primary accent (focused borders, links)
        ACCENT_BRIGHT   = "rgba(33b1ffff)",   -- Bright accent (active elements)
        ACCENT_SURFACE  = "rgba(1e3a5fff)",   -- Subtle accent (backgrounds, tints)
        ACCENT_MUTED    = "rgba(a8c4ffff)",   -- Desaturated accent (active text, subtle on)
        ACCENT_DIM      = "rgba(4d6fa8ff)",   -- Dark accent (tinted surfaces, pressed states)

        -- Semantic
        SUCCESS         = "rgba(42be65ff)",   -- Success
        WARNING         = "rgba(f1c21bff)",   -- Warning
        ERROR           = "rgba(ff5f5fff)",   -- Error
        INFO            = "rgba(3ddbd9ff)",   -- Info / teal
        SUCCESS_MUTED   = "rgba(aad9b8ff)",   -- Soft green (active text on dark, like ACCENT_MUTED)
        WARNING_MUTED   = "rgba(f5d97fff)",   -- Soft yellow (same idea)
        ERROR_MUTED     = "rgba(ffababff)",   -- Soft red (error text without being aggressive)

        -- Surfaces
        SURFACE         = "rgba(1e1e1eff)",   -- Slightly lifted from BG, below BG_HIGHLIGHT
        SURFACE_OVERLAY = "rgba(ffffff0f)",   -- White at 6% opacity, universal hover tint

        -- Extras
        SHADOW          = "rgba(0f0f0fee)",   -- Subtle shadow
        SECONDARY       = "rgba(be95ffff)",   -- Purple (notifications, tags)
        URGENT          = "rgba(ff832bff)",   -- Orange (urgent, badges)
    }
}
