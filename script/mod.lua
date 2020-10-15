-- Factorio-Lib: https://factoriolib.github.io/flib/index.html
local event = require("__flib__.event")

-- Load the planner
local ResearchQueue = require("script.queue")

local Planner = require("script.planner")
local PlanningStrategy = require("script.strategy")

local Mod = {}

function Mod.InitMod(e)
    Planner.Init(e)
    Mod.ApplyRuntimeSettings(e)
end
event.on_init(Mod.InitMod)
event.on_configuration_changed(Mod.InitMod)

function Mod.ApplyRuntimeSettings(e) ResearchQueue.ApplyRuntimeSettings(e) end
event.on_runtime_mod_setting_changed(Mod.ApplyRuntimeSettings)

function Mod.OnLoad(e)
    if global.research_planner == nil then return end

    -- Rehydrate all the strategies
    for force_name, force in pairs(global.research_planner) do
        PlanningStrategy.hydrate(global.research_planner[force_name])
    end
end
event.on_load(Mod.OnLoad)

-- Register the mod events
event.on_research_finished(function(e)
    Planner.TickResearchPlanner(e)
    ResearchQueue.NotifyResearchFinished(e)
end)

event.on_rocket_launched(ResearchQueue.DefaultUnlockBehaviour)

return Mod
