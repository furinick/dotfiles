---------------
--- Plugins ---
---------------

local mainMod = "SUPER"

-- split-monitor-workspaces setup
package.path = package.path .. ";./?.lua;./?/init.lua"
local smw = require("plugins.split-monitor-workspaces")

smw.setup({
	workspace_count = 5, -- matches the 5 workspaces used below
})

-- Workspaces (split-monitor-workspaces: per-monitor numbering)
for i = 1, 5 do
	local n = tostring(i)
	hl.bind(mainMod .. " + " .. n, smw.workspace(n))
	hl.bind(mainMod .. " + SHIFT + " .. n, smw.move_to_workspace_silent(n))
end
