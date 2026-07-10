-- ============================================================================
--  Monitors  (archfw13: Framework 13 internal panel + external fallback)
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Monitors/
--  Verified: empty output = fallback rule; mode "WIDTHxHEIGHT@RR"; "auto-up" pos
-- ============================================================================

-- Internal panel: Framework 13, 2880x1920 @ 120Hz, scale 2 (retina).
-- (was: monitor = eDP-1 , 2880x1920@120 , 0x0 , 2)
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1920@120",
    position = "0x0",
    scale    = 2,
})

-- Fallback for anything else (e.g. external monitors plugged in on the go):
-- highest resolution, placed above the internal panel, scale 2.
-- (was: monitor = , highres , auto-up , 2)
hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto-up",
    scale    = 2,
})
