-- ============================================================================
--  Machine profiles  —  single source of truth for per-host differences.
--
--  >>> Set `current` below to this host's name. <<<
--
--  The active profile is merged on top of `default`, so each named profile
--  only lists what DIFFERS. Add a new machine by adding an entry to `profiles`
--  (override only the fields that differ from `default`).
--
--  Fields consumed by the other modules:
--    monitors       list of hl.monitor specs
--    sensitivity    input.sensitivity (-1.0 .. 1.0)
--    touchpad       input.touchpad spec, or nil
--    gestures       list of hl.gesture specs
--    devices        list of hl.device specs
--    shadow         decoration.shadow spec
--    wallpaper      misc.force_default_wallpaper (-1 default / 0,1 disable mascot)
--    screenshot_key key for hyprshot binds ("PRINT" / "F11" / ...)
--    env_extra      list of { "VAR", "value" } machine-specific env vars
--    extra_binds    list of { mod=.., key=.., cmd=.. } machine-specific exec binds
--
--  Consumed via `require("modules.machine")`.
-- ============================================================================

-- >>> EDIT THIS LINE PER HOST <<<
local current = "g36archpc" -- "archfw13" | "g36archpc" | <new profile key>

local profiles = {
    -- Base profile (desktop-oriented). Also the fallback for any field a
    -- named profile leaves unset.
    default = {
        monitors = {
            { output = "DP-3", mode = "highrr", position = "auto",       scale = "auto", transform = 0, cm = "auto" },
            { output = "DP-4", mode = "highrr", position = "auto-right", scale = "auto", transform = 0, cm = "auto" },
        },
        sensitivity    = -0.5,
        touchpad       = nil, -- no touchpad section
        gestures       = {},  -- no hl.gesture entries
        devices        = {},  -- no hl.device entries
        shadow         = { enabled = false },
        wallpaper      = -1,  -- -1 = keep Hyprland's default anime mascot
        screenshot_key = "F11",
        env_extra = {
            -- NVIDIA driver hints + pin electron to wayland.
            { "LIBVA_DRIVER_NAME",            "nvidia"  },
            { "__GLX_VENDOR_LIBRARY_NAME",    "nvidia"  },
            { "ELECTRON_OZONE_PLATFORM_HINT", "wayland" },
        },
        extra_binds = {}, -- machine-specific exec binds
    },

    -- Framework 13 laptop (AMD APU, eDP panel, touchpad, logitech mice).
    archfw13 = {
        monitors = {
            { output = "eDP-1", mode = "2880x1920@120", position = "0x0",     scale = 2 },
            { output = "",      mode = "highres",       position = "auto-up", scale = 2 },
        },
        sensitivity = 0,
        touchpad    = { natural_scroll = false },
        gestures = {
            { fingers = 3, direction = "horizontal", action = "workspace" },
        },
        devices = {
            { name = "logitech-g-pro--1",  sensitivity = -1    },
            { name = "logitech-g502-hero", sensitivity = -0.75 },
        },
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a, -- == rgba(1a1a1aee)
        },
        wallpaper      = 0,    -- disable the anime mascot wallpaper
        screenshot_key = "PRINT",
        env_extra = {
            -- AMD: use the unified ozone hint (no NVIDIA vars).
            { "OZONE_PLATFORM_HINT", "auto" },
        },
        extra_binds = {
            -- lock screen + keyboard backlight (laptop-only)
            { mod = "SUPER", key = "L",                    cmd = "hyprlock" },
            { mod = "SUPER", key = "XF86MonBrightnessUp",   cmd = "brightnessctl -d *::kbd_backlight set +20%" },
            { mod = "SUPER", key = "XF86MonBrightnessDown", cmd = "brightnessctl -d *::kbd_backlight set 20%-" },
        },
    },

    -- Desktop. Currently identical to `default`; override fields here as it
    -- diverges.
    g36archpc = {},
}

assert(profiles[current],
    "machine.lua: unknown profile '" .. tostring(current) .. "'")

-- Merge: copy `default` first, then let the active profile's fields win.
local M = {}
for k, v in pairs(profiles.default) do M[k] = v end
for k, v in pairs(profiles[current]) do M[k] = v end
M.name = current

return M
