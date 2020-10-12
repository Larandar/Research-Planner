-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")
local string_array = require('__stdlib__/stdlib/utils/classes/string_array')

-- Ban
local BanResearchPacks = {packs = {}}
BanResearchPacks.__index = BanResearchPacks

function BanResearchPacks:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function BanResearchPacks:apply(force, technologies)
    -- Get all banned science-packs
    local banned_packs = string_array(table.values(self.packs))
    table.each(self.packs,
               function(p) banned_packs:add(p .. "-science-pack") end)

    return {}, table.filter(technologies, function(t)
        local used_packs = table.map(t.research_unit_ingredients,
                                     function(i) return i.name end)
        return not table.any(used_packs,
                             function(p) return banned_packs:has(p) end)
    end)
end

return {["filter.ban-research-packs"] = BanResearchPacks}
