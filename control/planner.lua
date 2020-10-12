-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')
local Game = require("__stdlib__/stdlib/game")

-- Stategies
local Strategies = {["first-found"] = require("control/strategies/first-found")}

local Planner = {}

function Planner.FinishedResearch(event)
    -- Only trigger on correct events
    if not (event and event.define_name == "on_research_finished") then
        return
    end

    local force = Game.get_force(event.research.force)
    if not force.current_research == nil then return end

    local planning_strategy =
        settings.global["research-planner-wip-planning-strategy"].value
    if planning_strategy == "no" then return end

    if Strategies[planning_strategy] == nil then
        game.print("ERROR: not implemented strategy: " .. planning_strategy)
        return
    end

    local next_tech = Strategies[planning_strategy].NextTech(force)
    if next_tech == nil then return end

    -- The name is not explicit but it only add to the research queue/current research
    force.add_research(next_tech)
end
Event.register(defines.events.on_research_finished, Planner.FinishedResearch)

return Planner
