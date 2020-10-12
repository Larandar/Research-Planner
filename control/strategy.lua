-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")

-- Load all defined rules
local DefinedRules = {}

DefinedRules = table.merge(DefinedRules, require("control/rules/sorting"))
-- DefinedRules = table.merge(DefinedRules, require("control/rules/filter"))

-- Class in charge of evaluating the ruleset
local PlanningStrategy = {ruleset = {{type = "depth-sorting"}}}
PlanningStrategy.__index = PlanningStrategy

function PlanningStrategy:new(o)
    o = o or {}
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
    local plan = {}

    -- We evaluate all rules
    for _, rule in pairs(self.ruleset) do
        local selection, remaining_techs = rule:apply(force, technologies)
        table.each(selection, function(x) table.insert(plan, x) end)
        technologies = remaining_techs
    end

    -- We add all remaining techs at the end of the plan
    table.each(technologies, function(x) table.insert(plan, x) end)

    -- We don't need the researched
    plan = table.filter(plan, function(t) return not t.researched end)
    return plan
end

return PlanningStrategy
