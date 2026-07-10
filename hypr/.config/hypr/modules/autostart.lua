-- ============================================================================
--  Autostart  (archfw13; from modules/autostart.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Autostart/
--
--  archfw13 starts hypridle via exec-once (NOT systemd user unit), so it MUST
--  be launched here. (g36archpc omitted it — that was a regression there.)
--
--  hyprlang `exec-once = cmd` -> `hl.exec_cmd("cmd")` inside an
--  hl.on("hyprland.start") hook.
-- ============================================================================

hl.on("hyprland.start", function()
    -- idle / lock daemon (archfw13 relies on this; do NOT remove)
    hl.exec_cmd("hypridle")

    -- bar + wallpaper + browser + terminal
    hl.exec_cmd("hyprpaper & waybar")
    hl.exec_cmd("kitty & firefox")

    -- tray / system applets
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")

    -- input method
    hl.exec_cmd("fcitx5 --replace -d")

    -- cursor theme (was `exec-once = hyprctl setcursor Adwaita 24` in input.conf on g36archpc;
    -- archfw13 original input.conf did not set a cursor — adding it for consistency)
    hl.exec_cmd("hyprctl setcursor Adwaita 24")
end)

-- NOTE: the old `exec-once = export OZONE_PLATFORM_HINT=auto` line was a no-op
-- (exporting an env var in a exec-once subprocess does not affect Hyprland's env).
-- It is handled properly via hl.env("OZONE_PLATFORM_HINT", "auto") in env.lua.
