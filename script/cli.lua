-- Factorio-Lib: https://factoriolib.github.io/flib/index.html
local table = require("__flib__.table")

-- CLI module
local CLI = {}

function CLI.exec(event)
    local calling_player = game.players[event.player_index]
    local force = calling_player.force

    local invoked_command = event.parameter
    local method = invoked_command:match("^%s*([%w-]+%s*)") or "help"

    (CLI[method:match("([%w-]+)")] or CLI.help)(calling_player, force,
                                                event.parameter:sub(#method + 1))
end

function CLI.help(player, force, parameters)
    player.print {"commands-help.research-planner"}
end

function CLI.show(player, force, parameters)
    table.for_each(global.research_planner[force.name].ruleset,
                   function(r) player.print(serpent.line(r)) end)
end

-- /research-planner add type [option-lua-table]
function CLI.add(player, force, parameters)
    -- Separate the
    local rule = {type = parameters:match("^%s*([%w.-]+)%s*")}
    local rule_args = parameters:match("^%s*[%w.-]+%s+(.+)$")
    if rule_args then
        local ok, res = serpent.load(rule_args)
        if ok and type(res) == "table" then
            rule = table.deep_merge {rule, res}
        else
            return CLI.help(player, force, parameters)
        end
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

return CLI
