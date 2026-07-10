-- ============================================================================
--  Environment variables  (archfw13)
--  Wiki: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--  NOTE: archfw13 is AMD — no NVIDIA env vars (unlike g36archpc).
-- ============================================================================

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/screenshot")

-- system
hl.env("EDITOR", "vim")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("OZONE_PLATFORM_HINT", "auto")

-- input - fcitx5
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
