local ResearchQueue = {}

function ResearchQueue.ApplyRuntimeSettings(event)
    local queue_setting = settings.global["research-planner-enable-queue"].value

    if queue_setting == "keep-map-settings" then
        -- Vanilla behaviour
        queue_setting = game.difficulty_settings.research_queue_setting
        for _, force in pairs(game.forces) do
            -- NOTE: Launching a rocket does not enable the queue if it was modified by a mod
            if queue_setting == "after-victory" then
                force.research_queue_enabled = force.rockets_launched > 0
            else
                force.research_queue_enabled = queue_setting == "always"
            end
        end

    elseif queue_setting == "enable" or queue_setting == "disable" then
        -- Just apply the same setting to all forces
        for _, force in pairs(game.forces) do
            force.research_queue_enabled = queue_setting == "enable"
        end

    else
        game.print {"errors.research-planner-queue-setting", queue_setting}
    end
end

function ResearchQueue.DefaultUnlockBehaviour(event)
    -- We only need to check when the map settings dificulty settings aggree
    if not (settings.global["research-planner-enable-queue"].value ==
        "keep-map-settings" and game.difficulty_settings.research_queue_setting ==
        "after-victory") then return end

    -- Enable the research queue now
    local force = event.rocket.force or event.rocket_silo.force
    force.research_queue_enabled = true
end

function ResearchQueue.NotifyResearchFinished(event)
    -- Get information from the event
    local research = event.research
    local force = event.research.force
    local sharing_setting = settings.global["research-planner-sharing"].value

    local research_localised_name = research.localised_name
    if research.research_unit_count_formula ~= nil and research.level > 2 then
        research_localised_name = {
            "technology-name.technology-with-level", research.localised_name,
            research.level - 1
        }
    end

    for _, other_force in pairs(game.forces) do
        if force.name == other_force.name then
            other_force.print {
                "messages.research-finished-self", force.name, research.name,
                research_localised_name
            }

        elseif force.get_friend(other_force) then
            if not sharing_setting == "no" then
                other_force.print {
                    "messages.research-finished-friend", force.name,
                    research.name, research_localised_name
                }
            end

        elseif not force.get_friend(other_force) then
            if sharing_setting == "always" then
                other_force.print {
                    "messages.research-finished-enemy", force.name,
                    research.name, research_localised_name
                }
            elseif sharing_setting == "secret-to-enemies" then
                local ingredients = research.research_unit_ingredients
                other_force.print {
                    "messages.research-finished-enemy-secret", force.name,
                    research.research_unit_count, ingredients[#ingredients].name
                }
            end
        end
    end
end

return ResearchQueue
