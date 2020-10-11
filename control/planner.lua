-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local Event = require('__stdlib__/stdlib/event/event')
local Game = require("__stdlib__/stdlib/game")

local Planner = {}

function Planner.researchable(tech)
    for _, prereq in pairs(tech["prerequisites"]) do
        if not prereq.researched then return false end
    end
    return true
end

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

    if planning_strategy == "first-one" then
        for _, tech in pairs(force.technologies) do
            if not tech.researched and Planner.researchable(tech) then
                force.add_research(tech.name)
                break
            end
        end
    elseif planning_strategy == "cheapest" then
        game.print("ERROR: not implemented strategy: " .. planning_strategy)
    else
        game.print("ERROR: not implemented strategy: " .. planning_strategy)
    end
end
Event.register(defines.events.on_research_finished, Planner.FinishedResearch)

return Planner
