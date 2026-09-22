-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("swaync")
	hl.exec_cmd("sh -c '$HOME/dotfiles/hosts/FreeCrow/hypr/scripts/random-wall.sh > /tmp/random-wall.log 2>&1'")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("elephant service enable")
	hl.exec_cmd("systemctl --user start elephant.service")
end)
