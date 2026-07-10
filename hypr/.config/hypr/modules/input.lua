-- ============================================================================
--  Input  (archfw13; from modules/input.conf)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Variables/ (#input, #gestures)
--        https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
--  Differs from g36archpc: sensitivity 0, touchpad block, 3-finger gesture
--  ACTIVE, two per-device logitech mice.
-- ============================================================================

hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",
        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification (g36archpc uses -0.5)

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Gestures. In 0.55 `workspace_swipe` / `_fingers` were removed in favor of
-- hl.gesture(). `workspace_swipe_distance` is still valid (Variables: #gestures).
-- archfw13 had the 3-finger horizontal swipe ACTIVE, so we register it here.
hl.config({
    gestures = {
        workspace_swipe_distance = 500,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Per-device config (https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/)
-- archfw13: two external logitech mice with custom sensitivity.
hl.device({
    name        = "logitech-g-pro--1",
    sensitivity = -1,
})

hl.device({
    name        = "logitech-g502-hero",
    sensitivity = -0.75,
})
