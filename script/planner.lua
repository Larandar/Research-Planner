-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')
local Game = require("__stdlib__/stdlib/game")
local table = require("__stdlib__/stdlib/utils/table")

local PlanningStrategy = require("script/strategy")
local Planner = {}

function Planner.Init(event)
    global.research_planner = global.research_planner or {}

    -- Init for each force
    for force_name, force in pairs(game.forces) do
        global.research_planner[force_name] =
            PlanningStrategy:new(global.research_planner[force_name] or {})
    end
end

function Planner.OnLoad(event)
    if global.research_planner == nil then return end
    -- Rehydrate all the strategies
    for force_name, force in pairs(global.research_planner) do
        PlanningStrategy.hydrate(global.research_planner[force_name])
    end
end
Event.on_load(Planner.OnLoad)

function Planner.FinishedResearch(event)
    -- Only trigger on correct events
    if not (event and event.define_name == "on_research_finished") then
        return
    end

    local force = Game.get_force(event.research.force)
    if not force.current_research == nil then return end

    local next_research = global.research_planner[force.name]:get_next(force)
    if next_research == nil then return end

    -- The name is not explicit but it only add to the research queue/current research
    force.add_research(next_research)
end
Event.register(defines.events.on_research_finished, Planner.FinishedResearch)

return Planner
