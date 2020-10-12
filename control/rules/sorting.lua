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

    local techs = table.values(technologies)
    table.sort(techs, depth_sorting)

    return {}, techs
end

return {["depth-sorting"] = DepthSorting}
