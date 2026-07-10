-- ============================================================================
--  Environment variables
--  Wiki: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--  Common vars here; machine-specific extras (NVIDIA vs OZONE) in
--  modules/machine.lua (M.env_extra).
-- ============================================================================

local M = require("modules.machine")

-- cursor / screenshots
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/screenshot")

-- system
hl.env("EDITOR", "vim")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- machine-specific (NVIDIA hints on desktop, OZONE on AMD laptop, ...)
for _, e in ipairs(M.env_extra) do
    hl.env(e[1], e[2])
end

-- input - fcitx5
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
