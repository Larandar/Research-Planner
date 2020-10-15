local PlanningStrategy = require("script.strategy")
local Planner = {}

function Planner.Init(event)
    global.research_planner = global.research_planner or {}

    -- Init for each force
    for force_name, force in pairs(game.forces) do
        global.research_planner[force_name] =
            PlanningStrategy:new(global.research_planner[force_name] or {})
    end
end

function Planner.TickResearchPlanner(event)
    local force = event.research.force
    if not force.current_research == nil then return end

    local next_research = global.research_planner[force.name]:get_next(force)
    if next_research == nil then return end

    -- The name is not explicit but it only add to the research queue/current research
    force.add_research(next_research)
end

return Planner
