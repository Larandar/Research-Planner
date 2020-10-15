-- Factorio-Lib: https://factoriolib.github.io/flib/index.html
local table = require("__flib__.table")

-- Missing find function from flib...
function table.find(tbl, condition)
    for k, v in pairs(tbl) do if condition(v, k, tbl) then return v end end
    return nil
end

-- Load all defined rules
local sorting_rules = require("script.rules.sorting")
local filtering_rules = require("script.rules.filter")

local DefinedRules = table.deep_merge {{}, sorting_rules, filtering_rules}

-- Class in charge of evaluating the ruleset
local PlanningStrategy = {ruleset = {{type = "sorting.by-research-depth"}}}
PlanningStrategy.__index = PlanningStrategy

function PlanningStrategy:new(o)
    o = table.deep_merge {{future_plan = {}}, o or {}}
    self.hydrate(o)
    return o
end

function PlanningStrategy:hydrate()
    setmetatable(self, PlanningStrategy)
    table.for_each(self.ruleset, function(rule)
        assert(DefinedRules[rule.type], "Undefined rule type: %s" .. rule.type)
        DefinedRules[rule.type]:hydrate(rule)
    end)
end

function PlanningStrategy:make_plan(force)
    -- We only need unresearched technologies as an array
    local technologies = table.filter(force.technologies,
                                      function(t) return not t.researched end)

    -- We assemble the plan
    local plan = {}

    -- We evaluate all rules
    for _, rule in pairs(self.ruleset) do
        local selection, remaining_techs = rule:apply(force, technologies)
        table.for_each(selection, function(x) table.insert(plan, x) end)
        technologies = remaining_techs
    end

    -- We add all remaining techs at the end of the plan
    table.for_each(technologies, function(x) table.insert(plan, x) end)

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
