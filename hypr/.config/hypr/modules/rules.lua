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

-- GFL2: Exilium (steam_app_3308670) — force tiling so it behaves like a
-- normal dwindle pane (wine-wayland native window, Unity re-renders on resize).
-- NOTE: requires PROTON_ENABLE_WAYLAND=1 in the game's Steam launch options.
-- Disabled for minimal-config testing; re-enable if auto-tiling is wanted.
-- hl.window_rule({
--     name = "gfl2-tile",
--     match = { class = "steam_app_3308670" },
--     float = false,
-- })

-- GFL2: no animations for the game window — makes the Super+G fullscreen
-- sandwich (see binds.lua) transition instantly with no flash.
-- Stack with sync_fullscreen=false (set via set_prop) for zero-flash instant flip.
-- Disabled: animations are smooth with sync_fullscreen=false and preferred.
-- hl.window_rule({
--     name = "gfl2-no-anim",
--     match = { class = "steam_app_3308670" },
--     no_anim = true,
-- })

-- GFL2: don't forward fullscreen state to the client (wine/Unity) — prevents
-- the content re-render flash during the Super+G tile sandwich.
-- Trade-off: the in-game "fullscreen" display mode won't resize the client;
-- manage fullscreen via Super+F / Super+G instead.
hl.window_rule({
    name = "gfl2-sync-fullscreen-off",
    match = { class = "steam_app_3308670" },
    sync_fullscreen = false,
})

-- TEST: opacity probe for gfl2 rule-matching diagnostics
-- hl.window_rule({
--     name = "gfl2-opacity-test",
--     match = { class = "steam_app_3308670" },
--     opacity = 0.75,
-- })

-- TEST: float probe
-- hl.window_rule({
--     name = "testfloat-probe",
--     match = { class = "testfloatapp" },
--     float = true,
-- })
