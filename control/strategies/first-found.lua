-- Starategy utils functions
local StrategyUtils = require("control/strategies/utils")

local FirstFoundStrategy = {}

-- The dummest idea ever, but it allow for quick testing
function FirstFoundStrategy.NextTech(force)
    for _, tech in pairs(force.technologies) do
        if StrategyUtils.is_researchable(tech) then return tech end
    end
end

return FirstFoundStrategy
