-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")

-- Load all defined rules
local DefinedRules = {}

DefinedRules = table.merge(DefinedRules, require("control/rules/sorting"))
DefinedRules = table.merge(DefinedRules, require("control/rules/filter"))

-- Class in charge of evaluating the ruleset
local PlanningStrategy = {ruleset = {{type = "sorting.by-research-depth"}}}
PlanningStrategy.__index = PlanningStrategy

function PlanningStrategy:new(o)
    o = table.merge({future_plan = {}}, o or {})
    setmetatable(o, PlanningStrategy)
    o:hydrate_ruleset()
    return o
end

function PlanningStrategy:hydrate_ruleset()
    self.ruleset = table.map(self.ruleset, function(rule)
        assert(DefinedRules[rule.type],
               "Undefined rule type: " .. tostring(rule.type))
        return DefinedRules[rule.type]:new(rule)
    end)
end

function PlanningStrategy:make_plan(force)
    -- We only need unresearched technologies as an array
    local technologies = table.filter(table.values(force.technologies),
                                      function(t) return not t.researched end)

    -- We assemble the plan
    local plan = {}

    -- We evaluate all rules
    for _, rule in pairs(self.ruleset) do
        local selection, remaining_techs = rule:apply(force, technologies)
        table.each(selection, function(x) table.insert(plan, x) end)
        technologies = remaining_techs
    end

    -- We add all remaining techs at the end of the plan
    table.each(technologies, function(x) table.insert(plan, x) end)

    -- Save plan for the future
    return table.map(plan, function(t) return t.name end)
end

function PlanningStrategy:get_next(force)
    -- Re-evaluate plan if the plan seem a little short
    if #self.future_plan < 10 then self.future_plan = self:make_plan(force) end

    -- If we are doing infinite research we need to make new plan each time
    if force.previous_research.research_unit_count_formula then
        self.future_plan = self:make_plan(force)
    end

    -- We don't need the researched, so we update the plan with updated infos
    self.future_plan = table.filter(self.future_plan, function(t)
        return not self:research(force, t).researched
    end)

    -- We get the first researchable research
    local next_research = table.find(self.future_plan, function(t)
        local research = self:research(force, t)
        return PlanningStrategy.is_researchable(research)
    end)

    return next_research
end

function PlanningStrategy:research(force, research_name)
    return force.technologies[research_name]
end

function PlanningStrategy.is_researchable(tech)
    -- Already researched tech can not be researched again
    if tech.researched then return false end

    -- If any of the prerequisites is not researched we can't start it
    for _, prereq in pairs(tech["prerequisites"]) do
        if not prereq.researched then return false end
    end

    -- Else it's possible
    return true
end

return PlanningStrategy
