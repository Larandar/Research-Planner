-- Standard Lib for factorio: https://afforess.github.io/Factorio-Stdlib/
local string = require('__stdlib__/stdlib/utils/string')
local table = require('__stdlib__/stdlib/utils/table')

local CLI = {}

function CLI.exec(event)
    local calling_player = game.players[event.player_index]
    local force = calling_player.force

    local parameters = string.split(event.parameter, " ")
    local method = table.remove(parameters, 1)

    if CLI[method] then
        CLI[method](calling_player, force, parameters)
    else
        calling_player.print {"commands-help.research-planner"}
    end
end

function CLI.show(player, force, parameters)
    table.each(global.research_planner[force.name].ruleset,
               function(r) player.print(serpent.line(r)) end)
end

function CLI.add(player, force, parameters)
    local rule = {type = table.remove(parameters, 1)}
    for _, p in ipairs(parameters) do
        p = string.split(p, "=")
        rule[p[1]] = string.split(p[2], ",")
    end

    table.insert(global.research_planner[force.name].ruleset, rule)
    global.research_planner[force.name]:hydrate()
end

function CLI.clear(player, force, parameters)
    global.research_planner[force.name].ruleset = {}
    global.research_planner[force.name]:hydrate()
end

commands.add_command("research-planner", {"commands-help.research-planner"},
                     CLI.exec)
