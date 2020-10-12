-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")

-- Starategy utils functions
local StrategyUtils = require("control/strategies/utils")

local FirstFoundStrategy = {}

-- The dummest idea ever, but it allow for quick testing
function FirstFoundStrategy.NextTech(force)
    return table.find(force.technologies, StrategyUtils.is_researchable)
end

return FirstFoundStrategy
