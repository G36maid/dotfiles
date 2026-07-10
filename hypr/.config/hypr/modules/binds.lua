-- ============================================================================
--  Keybindings  (archfw13; from modules/binds.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Binds/
--        https://wiki.hypr.land/Configuring/Basics/Dispatchers/  (hl.dsp.* surface)
--  archfw13-only binds: keyboard backlight (Super+brightness), hyprlock (Super+L),
--  screenshots on PRINT (not F11).
-- ============================================================================

local terminal    = "kitty"            -- was $terminal
local fileManager = "dolphin"          -- was $fileManager
local menu        = "wofi --show drun" -- was $menu

local mainMod     = "SUPER"            -- was $mainMod = SUPER

-- ---- apps / window ops ----
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())       -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + K", hl.dsp.layout("swapsplit"))   -- dwindle

-- original: `bind = supershift, Q, exec, firefox`
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("firefox"))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- ---- session: lock screen (archfw13-only; uses hyprlock) ----
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- ---- reload services (Super+B family) ----
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))                         -- hot-reload waybar
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("hyprctl reload"))                          -- reload hyprland config
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("killall hyprpaper && hyprpaper &disown"))   -- restart hyprpaper

-- ---- gaming / float+center on Super+N (two binds on the same key) ----
hl.bind(mainMod .. " + N", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + N", hl.dsp.window.center())

-- ---- workspace cycle + Tab ----
hl.config({ binds = { allow_workspace_cycles = true } })
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }))

-- ---- focus (arrows) ----
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- ---- swap window (Super+SHIFT+arrows; were `bindd` with descriptions) ----
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window to the left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window to the right" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

-- ---- workspaces 1-10 + move-window-silent ----
for i = 1, 10 do
    local key = i % 10 -- 10 -> key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    -- was `movetoworkspacesilent` (move without following) -> follow = false
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- ---- mouse: workspace scroll + drag/resize ----
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- ---- laptop multimedia (were `bindel`: repeat + locked) ----
-- FIX: g36archpc migration mistranslated `bindel` as release; `e` = repeat.
-- Using `repeating = true` so holding the key ramps continuously.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- ---- keyboard backlight (archfw13-only; Super + brightness keys) ----
hl.bind(mainMod .. " + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set +20%"))
hl.bind(mainMod .. " + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 20%-"))

-- ---- media keys (were `bindl`: locked) ----
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ---- screenshots (hyprshot) — archfw13 uses PRINT key (not F11) ----
hl.bind(mainMod .. " + PRINT",         hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("PRINT",                       hl.dsp.exec_cmd("hyprshot -m output"))
-- original `bind = $shiftMod, PRINT` — $shiftMod was never defined (dead bind).
-- Fixed to Super+Shift+Print (consistent with the same bug fixed on g36archpc).
hl.bind("SUPER + SHIFT + PRINT",       hl.dsp.exec_cmd("hyprshot -m region"))
