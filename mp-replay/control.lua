local player_events = require("player_events")

-- Players who are currently playing e.g. {1, 3}
local ignored_players = {2}

-- Player map
-- 1 Ximoltus / mysticamber
-- 2 macros4200 / heartosis
-- 3 Factoribert / Cyclo
-- 4 P1tta / Phreadward
-- 5 Cobai / thedoh
-- 6 lort_Z / typical_guy / thePiedPiper
-- 7 ardoRic / Franqly / RuneBoggler
-- 8 seky16 / JeHor


-- Set to "false" if you want to queue research yourself
local auto_queue_research = true

-- Pause other players with
-- /c __mp-replay__ global.paused=true

-- Unpause
-- /c __mp-replay__ global.paused=false


-- Set other player speed (1 is default, 0.5 is half, 2 is double, etc)
-- /c __mp-replay__ global.speed=0.5


-- For testing what's going wrong
local debug = false


-- Don't go any lower...

local events_to_run = {}

local ignored_player_map = {}
for _, id in ipairs(ignored_players) do
    ignored_player_map[id] = true
end
script.on_init(function()
   global.tick = 0
   global.mp_event_index = 1
   global.player_entities = {}
   for i=1,8 do
    global.player_entities[i] = game.get_surface("nauvis").create_entity{position={5,-5}, name="character", force="player"}
   end
   global.paused = false
   global.speed = 1
end)

local player_dropped = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.entity_name, event.position)
    -- If they drop into something that doesn't exist, fine...
    if entity == nil then
        return true
    end
    if event.entity_name == "burner-mining-drill" or entity.type == "furnace" or event.entity_name == "boiler" then
        local inv = entity.get_inventory(defines.inventory.fuel)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "container" then
        local inv = entity.get_inventory(defines.inventory.chest)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "assembling-machine" or entity.type == "lab" then
        local inv = entity.get_inventory(defines.inventory.assembling_machine_input)
        inv.insert({name=event.item_name, count=event.count})
    else
        if debug then
            game.print("drop " .. event.entity_name)
        end
    end
    return true
end

local player_took = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.entity_name, event.position)
    -- If they take from something that doesn't exist, fine...
    -- or if they're picking up the entity...
    if entity == nil or entity.name == event.entity_name then
        return true
    end
    -- We could also try to detect taking from inputs of an assembling-machine based on types...
    if entity.type == "furnace" or entity.type == "assembling-machine" then
        local inv
        if entity.type == "furnace" and event.name == "coal" then
            inv = entity.get_inventory(defines.inventory.fuel)
        else
            inv = entity.get_inventory(defines.inventory.assembling_machine_output)
        end
        inv.remove({name=event.item_name, count=event.count})
    elseif entity.type == "container" then
        local inv = entity.get_inventory(defines.inventory.chest)
        inv.remove({name=event.item_name, count=event.count})
    elseif entity.type == "lab" then
        local inv = entity.get_inventory(defines.inventory.assembling_machine_input)
        inv.remove({name=event.item_name, count=event.count})
    elseif entity.type == "simple-entity" or entity.type == "tree" then
    else
        if game.debug then
            game.print("take " .. event.entity_name)
        end
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

local rotate_entity = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil then
        return true
    end
    entity.direction = event.direction
    return true
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

local on_research_started = function(event)
    if not auto_queue_research then
        return true
    end
    return game.forces.player.add_research(event.name)
end

local on_player_changed_position = function(event)
    global.player_entities[event.player_index].teleport(event.position)
    return true
end

script.on_event(defines.events.on_tick, function(tick_event)
    if global.paused then
        return
    end
    local last_tick = math.floor(global.tick)
    global.tick = global.tick + global.speed
    local new_tick = global.tick
    for tick = last_tick,new_tick do
        if tick % 300 == 0 and #events_to_run > 0 then
            if debug then
                game.print(#events_to_run .. " events are failing to run")
            end
        end
        while global.mp_event_index <= #player_events and tick >= player_events[global.mp_event_index].tick do
            local ev = player_events[global.mp_event_index]
            if not ignored_player_map[ev.player_index] then
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
                elseif event.event_type == "on_player_rotated_entity" then
                    noerr, success = pcall(rotate_entity, event)
                elseif event.event_type == "player_dropped" then
                    noerr, success = pcall(player_dropped, event)
                elseif event.event_type == "player_took" then
                    noerr, success = pcall(player_took, event)
                elseif event.event_type == "set_recipe" then
                    noerr, success = pcall(set_recipe, event)
                elseif event.event_type == "on_research_started" then
                    noerr, success = pcall(on_research_started, event)
                elseif event.event_type == "on_player_changed_position" then
                    noerr, success = pcall(on_player_changed_position, event)
                else
                    success = true
                    if debug then
                        game.print("bad event: " .. serpent.line(event))
                    end
                end
                if noerr == false then
                    if debug then
                        game.print("error (" .. serpent.line(success) .. ") event: " .. serpent.line(event))
                    end
                elseif not success then
                    if event.tick == tick then
                        if debug then
                            game.print("failed to execute event: " .. serpent.line(event))
                        end
                    end
                    table.insert(new_events_to_run, event)
                end
            end
        end
        events_to_run = new_events_to_run
    end

end)