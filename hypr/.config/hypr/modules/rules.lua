-- ============================================================================
--  Window rules  (from modules/rules.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--  No machine-specific rules.
-- ============================================================================

-- Ignore window maximize requests from all apps
hl.window_rule({
    name = "global-suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Dolphin (and other KDE apps) spawned BY another app — e.g. Firefox
-- "Show in folder" via the org.freedesktop.FileManager1 D-Bus service —
-- opens as a transient window with a parent set. Hyprland auto-floats
-- windows with a parent (XWaylandManager::shouldBeFloated), so they never
-- enter the tiling layout. Force them to tile like a normally-launched one.
-- Diagnose other offenders with: hyprctl clients | grep -E 'class|floating'
hl.window_rule({
    name = "dolphin-tile",
    match = { class = "^org\\.kde\\.dolphin$" },
    tile = true,
})

-- KDE portal file dialogs. FileChooser is routed to xdg-desktop-portal-kde in
-- ~/.config/xdg-desktop-portal/hyprland-portals.conf, so EVERY app's
-- open/save dialog (Firefox "另存新檔", Zed, ...) is a transient window of
-- class org.freedesktop.impl.portal.desktop.kde. Hyprland floats those with
-- a parent (and the dialog opens monitor-sized), so force-tiling puts it into
-- the normal dwindle layout. Looks like Dolphin but it is NOT org.kde.dolphin.
hl.window_rule({
    name = "kde-portal-dialog-tile",
    match = { class = "^org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde$" },
    tile = true,
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
