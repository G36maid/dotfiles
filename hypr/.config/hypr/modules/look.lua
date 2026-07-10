-- ============================================================================
--  Look & feel  (archfw13; from modules/general.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Variables/
--        https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
--  Differs from g36archpc: shadow ENABLED, force_default_wallpaper = 0.
-- ============================================================================

-- ---- general (https://wiki.hypr.land/Configuring/Basics/Variables/#general) ----
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },
})

-- ---- decoration (archfw13: shadow enabled) ----
hl.config({
    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        -- shadow was ENABLED on archfw13 (range 4, render_power 3, rgba(1a1a1aee)).
        -- rgba(1a1a1aee) == legacy ARGB 0xee1a1a1a (same color).
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
})

-- ---- animations ----
hl.config({ animations = { enabled = true } })

-- user's custom bezier (was: `bezier = myBezier, 0.05, 0.9, 0.1, 1.05`)
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

-- user's animations (were `animation = <leaf>, 1, <speed>, <curve>[, style]`)
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

-- ---- layouts ----
hl.config({
    dwindle = {
        preserve_split = true, -- you probably want this
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

-- ---- misc (archfw13: anime mascot wallpaper disabled = 0) ----
hl.config({
    misc = {
        force_default_wallpaper = 0,    -- 0 or 1 disables the anime mascot wallpaper
        disable_hyprland_logo   = false,
    },
})
