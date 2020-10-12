-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')
local Game = require("__stdlib__/stdlib/game")

local PlanningStrategy = require("control/strategy")
local Planner = {}

-- FIXME: ULTRA WIP
local current_strategy = PlanningStrategy:new()
local force_plan = {}

function Planner.FinishedResearch(event)
    -- Only trigger on correct events
    if not (event and event.define_name == "on_research_finished") then
        return
    end

    local force = Game.get_force(event.research.force)
    if not force.current_research == nil then return end

    if #force_plan < 10 then force_plan = current_strategy:make_plan(force) end

    -- The name is not explicit but it only add to the research queue/current research
    force.add_research(table.remove(force_plan, 1))
end
Event.register(defines.events.on_research_finished, Planner.FinishedResearch)

return Planner
