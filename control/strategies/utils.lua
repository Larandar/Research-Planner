-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")

local StrategyUtils = {}

-- Return if a tech can be researched now
function StrategyUtils.is_researchable(tech)
    -- Already researched tech can not be researched again
    if tech.researched then return false end
    -- If any of the prerequisites is not researched we can't start it
    for _, prereq in pairs(tech["prerequisites"]) do
        if not prereq.researched then return false end
    end
    return true
end

-- Return a copy of the research table fitered for researchable techs only
function StrategyUtils.filter_researchable(techs)
    return table.filter(techs, StrategyUtils.is_researchable)
end

return StrategyUtils
