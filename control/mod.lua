-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')

-- Load the planner
local ResearchQueue = require("control/queue")
local Planner = require("control/planner")

local Mod = {}

function Mod.OnInit(event)
    Mod.ApplyStartupSettings()
    Mod.ApplyRuntimeSettings()
end
Event.on_init(Mod.OnInit)

function Mod.ApplyStartupSettings(event) end
Event.on_configuration_changed(Mod.ApplyStartupSettings)

function Mod.ApplyRuntimeSettings(event)
    ResearchQueue.ApplyRuntimeSettings(event)
end
Event.register(defines.events.on_runtime_mod_setting_changed,
               Mod.ApplyRuntimeSettings)

return Mod
