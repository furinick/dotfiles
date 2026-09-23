-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Qt theming
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Editor
hl.env("EDITOR", "nvim")
hl.env("VISUAL", "nvim")

-- Wayland
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- AMD
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")

-- Dark mode
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("COLORSCHEME", "dark")

-- Cursor
hl.env("HYPRCURSOR_THEME", "theme_Posys-Cursor-Scalable-Black")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "theme_Posys-Cursor-Scalable-Black")
hl.env("XCURSOR_SIZE", "24")

-- Cursor fix for games
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
