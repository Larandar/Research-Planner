-- Factorio-Lib: https://factoriolib.github.io/flib/index.html
local table = require("__flib__.table")

-- Ban research pack fron the planning
local BanResearchPacks = {packs = {}}
BanResearchPacks.__index = BanResearchPacks
function BanResearchPacks:hydrate(o) setmetatable(o, self) end

function BanResearchPacks:apply(force, technologies)
    return {}, table.filter(technologies, self:filter())
end

function BanResearchPacks:filter()
    local function contain_banned_sciend(packs, suffix)
        for _, pack in ipairs(packs) do
            for _, p in ipairs(self.packs) do
                if pack == p .. (suffix or "") then return true end
            end
        end
        return false
    end

    return function(tech)
        -- Present packs
        local used_packs = table.map(tech.research_unit_ingredients,
                                     function(i) return i.name end)

        -- Get all banned science-packs with complete name
        if contain_banned_sciend(used_packs) then return false end

        -- Get all banned science-packs ending with "-science-packs"
        if contain_banned_sciend(used_packs, "-science-pack") then
            return false
        end

        -- There was no match then
        return true
    end
end

-- Ban research family from the planning
local BanResearchTypes = {types = {}}
BanResearchTypes.__index = BanResearchTypes
function BanResearchTypes:hydrate(o) setmetatable(o, self) end

function BanResearchTypes:apply(force, technologies)
    return {}, table.filter(technologies, self:filter())
end

function BanResearchTypes:filter()
    -- Filtering by prefix
    local function starts_with(s, p) return s:sub(0, #p) == p end

    return function(tech)
        -- The first match stop the loockup
        for _, banned_type in ipairs(self.types) do
            if starts_with(tech.name, banned_type) then return false end
        end

        -- There was no match then
        return true
    end
end

return {
    ["filter.ban-research-packs"] = BanResearchPacks,
    ["filter.ban-research-types"] = BanResearchTypes
}
