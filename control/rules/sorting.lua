-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local table = require("__stdlib__/stdlib/utils/table")

-- Sorting by depth of availability in the research tree
local DepthSorting = {}
DepthSorting.__index = DepthSorting

function DepthSorting:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function DepthSorting:apply(force, technologies)
    local depths = {}

    local function get_depth(tech)
        -- Recursion end
        if table.count_keys(tech.prerequisites) == 0 then return 1 end
        if tech.researched then return 1 end

        -- Only compute recompute non cached depths
        if depths[tech.name] == nil then
            -- Recursively use the max of the prerequisites
            local prereq_depths = table.map(tech.prerequisites, get_depth)
            prereq_depths = table.values(prereq_depths)
            depths[tech.name] = 1 + (table.max(prereq_depths) or 0)
        end

        return depths[tech.name]
    end

    local function depth_sorting(a, b) return get_depth(a) < get_depth(b) end
    table.sort(technologies, depth_sorting)

    return {}, technologies
end

local CheapnessSorting = {
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
CheapnessSorting.__index = CheapnessSorting

function CheapnessSorting:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function CheapnessSorting:apply(force, technologies)
    table.sort(technologies,
               function(a, b) return self:cost_of(a) < self:cost_of(b) end)
    return {}, technologies
end

function CheapnessSorting:cost_of(tech)
    local pack_cost = 0
    for _, i in ipairs(tech.research_unit_ingredients) do
        if self.pack_weights[i.name] then
            pack_cost = pack_cost + self.pack_weights[i.name]
        else
            -- This is a warning
            print("Could not find pack weight (using default: 10):" .. i.name)
            print("You can open an github issue to provide a better value.")
            pack_cost = pack_cost + 10
        end
    end
    return pack_cost * tech.research_unit_count
end

return {
    ["sorting.by-research-depth"] = DepthSorting,
    ["sorting.by-cheapness"] = CheapnessSorting
}
