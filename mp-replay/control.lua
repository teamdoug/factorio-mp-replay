local player_events = require("player_events")

local my_index = 9

local events_to_run = {}
script.on_init(function()
   global.mp_event_index = 1
end)

local player_dropped = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.entity_name, event.position)
    -- If they drop into something that doesn't exist, fine...
    if entity == nil then
        return true
    end
    if event.entity_name == "burner-mining-drill" or event.entity_name == "stone-furnace"  or event.entity_name == "boiler" then
        local inv = entity.get_inventory(defines.inventory.fuel)
        inv.insert({name=event.item_name, count=event.count})
    elseif event.entity_name == "wooden-chest" then
        local inv = entity.get_inventory(defines.inventory.chest)
        inv.insert({name=event.item_name, count=event.count})
    else
        game.print("drop " .. event.entity_name)
    end
    return true
end

local mine_entity = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil then
        -- rocks and trees we don't care if something else killed them
        if event.type == "simple-entity" or event.type == "tree" then
            return true
        else
            return false
        end
    end
    return entity.destroy()
end

local set_recipe = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil then
        return false
    end
    entity.set_recipe(event.recipe)
    return true
end

local build_entity = function(event)
    entity = game.surfaces["nauvis"].create_entity{
        name = event.name,
        position = event.position,
        direction = event.direction,
        force = "player",
        spill = false,
        recipe = event.recipe,
        type = event.belt_to_ground_type,
        bar = event.bar,
        stack = event.stack,
        inner_name = event.ghost_name
    }
    return entity ~= nil
end

script.on_event(defines.events.on_tick, function(tick_event)
    local tick = tick_event.tick
    if tick % 300 == 0 and #events_to_run > 0 then
        game.print(#events_to_run .. " events are failing to run")
    end
    while global.mp_event_index <= #player_events and tick >= player_events[global.mp_event_index].tick do
        local ev = player_events[global.mp_event_index]
        if ev.player_index ~= my_index then
            table.insert(events_to_run, ev)
        end
        global.mp_event_index = global.mp_event_index + 1
    end
    local new_events_to_run = {}
    for _, event in ipairs(events_to_run) do
        if (tick - event.tick) % 60 ~= 0 then
            table.insert(new_events_to_run, event)
        else
            local noerr = true
            local success
            if event.event_type == "on_player_mined_entity" then
                noerr, success = pcall(mine_entity, event)
            elseif event.event_type == "on_built_entity" then
                noerr, success = pcall(build_entity, event)
            elseif event.event_type == "player_dropped" then
                noerr, success = pcall(player_dropped, event)
            elseif event.event_type == "set_recipe" then
                noerr, success = pcall(set_recipe, event)
            else
                success = true
                game.print("bad event: " .. serpent.line(event))
            end
            if noerr == false then
                game.print("error (" .. serpent.line(success) .. ") event: " .. serpent.line(event))
            elseif not success then
                if event.tick == tick then
                    game.print("failed to execute event: " .. serpent.line(event))
                end
                table.insert(new_events_to_run, event)
            end
        end
    end
    events_to_run = new_events_to_run

end)