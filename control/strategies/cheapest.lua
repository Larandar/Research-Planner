-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")

-- Starategy utils functions
local StrategyUtils = require("control/strategies/utils")

local CheapestStrategy = {
    -- By default it's the total raw time is minutes that is used
    pack_weights = {
        ["automation-science-pack"] = 0.25,
        ["logistic-science-pack"] = 0.5,
        ["military-science-pack"] = 2,
        ["chemical-science-pack"] = 4,
        ["utility-science-pack"] = 20,
        ["production-science-pack"] = 21,
        ["space-science-pack"] = 100
    }
}

function CheapestStrategy.TechCost(tech)
    local pack_cost = 0
    for _, i in ipairs(tech.research_unit_ingredients) do
        if CheapestStrategy.pack_weights[i.name] then
            pack_cost = pack_cost + CheapestStrategy.pack_weights[i.name]
        else
            -- This is a warning
            print("Could not find pack weight (using default: 10):" .. i.name)
            print("You can open an github issue to provide a better value.")
            pack_cost = pack_cost + 10
        end
    end
    return pack_cost * tech.research_unit_count / tech.research_unit_energy
end

-- The dummest idea ever, but it allow for quick testing
function CheapestStrategy.NextTech(force)
    local techs = StrategyUtils.filter_researchable(force.technologies)
    table.sort(techs, function(a, b)
        return CheapestStrategy.TechCost(a) < CheapestStrategy.TechCost(b)
    end)
    return table.first(techs)
end

return CheapestStrategy
