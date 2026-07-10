-- ============================================================================
--  Hyprland config entry point
--  Hyprland >= 0.55 (Lua). Replaces hyprland.conf.
--  https://wiki.hypr.land/Configuring/Start/
--
--  Per-host settings live in modules/machine.lua — set `current` there to
--  this host's profile. Everything below is identical across machines.
-- ============================================================================

require("modules/monitors")
require("modules/env")
require("modules/look")
require("modules/input")
require("modules/binds")
require("modules/rules")
require("modules/autostart")
