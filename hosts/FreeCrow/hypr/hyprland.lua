local home = os.getenv("HOME")
local shared_hypr = home .. "/dotfiles/shared/hypr"

package.path = shared_hypr .. "/?.lua;" .. shared_hypr .. "/?/init.lua;" .. package.path

require("hyprland")
require("conf/monitors")
require("conf/input")
