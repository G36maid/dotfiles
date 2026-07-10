-- ============================================================================
--  Monitors
--  Wiki: https://wiki.hypr.land/Configuring/Basics/Monitors/
--  Monitor list is per-host — see modules/machine.lua (M.monitors).
-- ============================================================================

local M = require("modules.machine")

for _, mon in ipairs(M.monitors) do
    hl.monitor(mon)
end
