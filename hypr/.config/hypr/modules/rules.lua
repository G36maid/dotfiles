-- ============================================================================
--  Window rules  (archfw13; from modules/rules.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--  Identical to g36archpc — no machine-specific rules.
-- ============================================================================

-- Ignore window maximize requests from all apps
hl.window_rule({
    name = "global-suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag/focus issues.
-- In Lua, boolean match fields replace the hyprlang `match:xwayland = 1` style.
hl.window_rule({
    name = "xwayland-drag-fix",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
