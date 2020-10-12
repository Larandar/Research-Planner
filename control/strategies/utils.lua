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

return StrategyUtils
