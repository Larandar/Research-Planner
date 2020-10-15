-- Factorio-Lib: https://factoriolib.github.io/flib/index.html
local table = require("__flib__.table")
local math = require("__flib__.math")

-- Sorting by depth of availability in the research tree
local DepthSorting = {}
DepthSorting.__index = DepthSorting
function DepthSorting:hydrate(o) setmetatable(o, self) end

function DepthSorting:apply(force, technologies)
    table.sort(technologies, self:compare())
    return {}, technologies
end

-- Generate a comparaison function
function DepthSorting:compare()
    -- Local depth mapping
    local depths = {}

    -- We need to ignore the third argument of table.reduce
    local function max(a, b) return math.max(a, b) end

    -- Compute depth of a tech, using cache to not go twice over a tech tree
    local function depth(tech)
        -- Recursion end
        if #tech.prerequisites == 0 then return 1 end
        if tech.researched then return 1 end

        -- Only compute recompute non cached depths
        if depths[tech.name] == nil then
            -- Recursively use the max of the prerequisites
            local prereq_depths = table.map(tech.prerequisites, depth)
            local prereq_max = table.reduce(prereq_depths, max, 1)
            -- We add a level for depth
            depths[tech.name] = prereq_max + 1
        end

        return depths[tech.name]
    end

    return function(a, b) return depth(a) < depth(b) end
end

-- Sort by how cheap a tech is to produce and research
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
function CheapnessSorting:hydrate(o) setmetatable(o, self) end

function CheapnessSorting:apply(force, technologies)
    table.sort(technologies, self:compare())
    return {}, technologies
end

function CheapnessSorting:compare()
    -- Ingredient cost
    local function ingredients_cost(total_cost, i)
        if self.pack_weights[i.name] then
            return total_cost + self.pack_weights[i.name]
        else
            -- This is a warning
            print("Could not find pack weight (using default: 10):" .. i.name)
            print("You can open an github issue to provide a better value.")
            return total_cost + 10
        end
    end

    -- Cost function
    local function cost_of(tech)
        local total_cost = table.reduce(tech.research_unit_ingredients,
                                        ingredients_cost, 0)
        return tech.research_unit_count * total_cost
    end

    return function(a, b) return cost_of(a) < cost_of(b) end
end

-- Sort by how quickly it is to research
local ResearchSpeedSorting = {}
ResearchSpeedSorting.__index = ResearchSpeedSorting
function ResearchSpeedSorting:hydrate(o) setmetatable(o, self) end

function ResearchSpeedSorting:apply(force, technologies)
    table.sort(technologies, self:compare())
    return {}, technologies
end

function ResearchSpeedSorting:compare()
    -- Cost function
    local function speed_of(tech)
        return tech.research_unit_count * tech.research_unit_energy
    end

    return function(a, b) return speed_of(a) < speed_of(b) end
end

return {
    ["sorting.by-research-depth"] = DepthSorting,
    ["sorting.by-cheapness"] = CheapnessSorting,
    ["sorting.by-speed"] = ResearchSpeedSorting
}
