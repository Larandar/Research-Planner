-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')

-- Load the planner
local ResearchQueue = require("script/queue")
local Planner = require("script/planner")

local Mod = {}

function Mod.InitMod(event)
    Planner.Init(event)
    Mod.ApplyRuntimeSettings(event)
end
Event.on_init(Mod.InitMod)
Event.on_configuration_changed(Mod.InitMod)

function Mod.ApplyRuntimeSettings(event)
    ResearchQueue.ApplyRuntimeSettings(event)
end
Event.register(defines.events.on_runtime_mod_setting_changed,
               Mod.ApplyRuntimeSettings)

return Mod
