-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')
local Game = require("__stdlib__/stdlib/game")

local PlanningStrategy = require("control/strategy")
local Planner = {}

-- FIXME: ULTRA WIP
local current_strategy = PlanningStrategy:new()

function Planner.FinishedResearch(event)
    -- Only trigger on correct events
    if not (event and event.define_name == "on_research_finished") then
        return
    end

    local force = Game.get_force(event.research.force)
    if not force.current_research == nil then return end

    local next_research = current_strategy:get_next(force)
    if next_research == nil then return end

    -- The name is not explicit but it only add to the research queue/current research
    force.add_research(next_research)
end
Event.register(defines.events.on_research_finished, Planner.FinishedResearch)

return Planner
