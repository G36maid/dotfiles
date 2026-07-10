-- ============================================================================
--  Input  (from modules/input.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Variables/ (#input, #gestures)
--        https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
--  Per-host: sensitivity, touchpad, gestures, devices — see modules/machine.lua.
-- ============================================================================

local M = require("modules.machine")

hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",
        follow_mouse = 1,
        sensitivity  = M.sensitivity,
        touchpad     = M.touchpad, -- nil on hosts without a touchpad
    },
})

-- Gestures. In 0.55 `workspace_swipe` / `_fingers` were removed in favor of
-- hl.gesture(); `workspace_swipe_distance` is still valid (Variables: #gestures).
hl.config({
    gestures = {
        workspace_swipe_distance = 500,
    },
})

-- Per-host gesture registrations + device configs (see modules/machine.lua).
for _, g in ipairs(M.gestures) do hl.gesture(g) end
for _, d in ipairs(M.devices)  do hl.device(d) end
