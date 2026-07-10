-- ============================================================================
--  Autostart  (from modules/autostart.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Autostart/
--
--  hypridle is started here via exec-once (NOT the systemd user service):
--  these hosts do not use UWSM and graphical-session.target is not started,
--  so the shipped hypridle.service would never launch. exec-once works
--  everywhere and is the canonical method without a systemd session.
--
--  hyprlang `exec-once = cmd` -> hl.exec_cmd("cmd") inside an
--  hl.on("hyprland.start") hook.
-- ============================================================================

hl.on("hyprland.start", function()
    -- idle / lock daemon
    hl.exec_cmd("hypridle")

    -- bar + wallpaper + browser + terminal
    hl.exec_cmd("hyprpaper & waybar")
    hl.exec_cmd("kitty & firefox")

    -- tray / system applets
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")

    -- input method
    hl.exec_cmd("fcitx5 --replace -d")

    -- cursor theme (was `exec-once = hyprctl setcursor Adwaita 24`)
    hl.exec_cmd("hyprctl setcursor Adwaita 24")
end)
