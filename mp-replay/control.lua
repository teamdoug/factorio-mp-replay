local player_events = require("player_events")


-- For testing what's going wrong
local debug = false


local events_to_run = {}

local player_names = {
    'Cyclomactic',
    'Phredward',
    'mysticamber',
    'Franqly/RuneBoggler',
    'typical_guy/thePiedPiper',
    'JeHor',
    'heartosis',
    'thedoh'
}


local player_colors = {
    {1,0,0},
    {1,.4,0},
    {1,1,0},
    {0,1,0},
    {0,1,1},
    {.7,.5,1},
    {1,0,1},
    {1,1,1}
}

local toggle_ignore_player = function(id, state, player_flow)
    if global.ignored_player_map[id] == state then
        return
    end
    if player_flow then
        player_flow["mpr_player_flow_"..id]["mpr_player_toggle"].state = state
    end
    global.ignored_player_map[id] = state
    if state then
        rendering.destroy(global.player_labels[id])
        global.player_entities[id].destroy()
    else
        local surf = game.get_surface("nauvis")
        global.player_entities[id] = surf.create_entity{
            position=global.player_positions[id],
            direction=global.player_directions[id],
            name="character-no-clip",
            force="player",
            }
        global.player_entities[id].color = player_colors[id]
        global.player_labels[id] = rendering.draw_text{
            text = player_names[id],
            surface = surf,
            target = global.player_entities[id],
            target_offset = {0, -2.5},
            alignment = "center",
            color = player_colors[id],
            scale = 2,
        }
    end
    for _, player in pairs(game.players) do
        if player.gui.screen.mpr_main_frame then
            player.gui.screen.mpr_main_frame.mpr_main_flow.mpr_player_flow["mpr_player_flow_"..id].mpr_player_toggle.state = state
        end
    end
end

script.on_init(function()
    global.last_tick = -1
    global.tick = 0
    global.mp_event_index = 1
    global.player_entities = {}
    global.ignored_player_map = {}
    global.player_positions = {}
    global.player_directions = {}
    global.player_labels = {}
    global.time_labels = {}
    for i=1,8 do
        global.ignored_player_map[i] = true
        global.player_positions[i] = {5, -5}
        global.player_directions[i] = 0
        toggle_ignore_player(i, false, nil)
    end
    global.paused = true
    global.speed = 1
    global.players = {}
    -- player index to id of the player they're playing as
    global.current_player_map = {}
    global.current_reversed_player_map = {}
    global.entity_highlights = {}
end)


script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    if debug and player.name ~= "heartosis" then  
        debug = false
    end
    local extra_speed_control = player.name == "heartosis"
    local name = player.name:lower()
    for i=1,8 do
        local check_names = player_names[i]:lower()
        for check_name in string.gmatch(check_names, "[a-z_]+") do
            if check_name == name then
                toggle_ignore_player(i, true, nil)
                global.current_player_map[event.player_index] = i
                global.current_reversed_player_map[i] = event.player_index
                game.print(player.name .. " joined. Ignoring player " .. i .. ": " .. player_names[i])
            end
        end
    end

    global.players[event.player_index] = {
        controls_visible = true,
        players_visible = true
    }

    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="mpr_main_frame", caption="MP Replay"}
    local main_flow = main_frame.add{type="flow", name="mpr_main_flow", direction="vertical"}
    main_flow.add{type="checkbox", name="mpr_pause", caption="Paused", state=global.paused}
    local controls_flow = main_flow.add{type="flow", name="mpr_controls_flow", direction="horizontal"}
    controls_flow.add{type="label", name="mpr_bot_speed_label", caption="Bot Speed"}
    local bot_speed = controls_flow.add{type="textfield", name="mpr_bot_speed", numeric=true, allow_decimal=true, lose_focus_on_confirm=true, text="1"}
    bot_speed.style.maximal_width=50
    bot_speed.style.minimal_width=50
    local speed_set = controls_flow.add{type="button", name="mpr_speed_set", caption="✓"}
    speed_set.style.size = {40, 30}
    local time_flow = controls_flow.add{type="flow", name="time", direction="vertical"}
    global.time_labels[event.player_index] = time_flow.add{type="label", name="time_label", caption="0:00:00"}
    if extra_speed_control then
        local speed_flow = main_flow.add{type="flow", name="speed", direction="horizontal"}
        local a = speed_flow.add{type="button", name="pause", caption="‖"}
        a.style.maximal_width=35
        a.style.minimal_width=35
        local b = speed_flow.add{type="button", name="play", caption="▶"}
        b.style.maximal_width=40
        b.style.minimal_width=40
        local c = speed_flow.add{type="button", name="fast", caption="▶▶"}
        c.style.maximal_width=60
        c.style.minimal_width=60
        local d = speed_flow.add{type="button", name="fastest", caption="▶▶▶"}
        d.style.maximal_width=70
        d.style.minimal_width=70
        global.tick_label = time_flow.add{type="label", name="tick_label", caption="0"}
    end
    local player_header_flow = main_flow.add{type="flow", name="mpr_player_header_flow", direction="horizontal"}
    player_header_flow.add{type="label", name="mpr_players_label", caption="Players"}
    player_header_flow.add{type="button", name="mpr_players_hide", caption="Hide"}
    player_header_flow.add{type="button", name="mpr_players_show", caption="Show", visible=false}
    local player_flow = main_flow.add{type="flow", name="mpr_player_flow", direction="vertical"}
    player_flow.add{type="label", name="mpr_players_label2", caption="Me    Ignored"}
    for i=1,8 do
        local this_flow = player_flow.add{type="flow", name="mpr_player_flow_"..i, direction="horizontal"}
        local cb = this_flow.add{type="button", name="mpr_player_set", tags={id=i}}
        this_flow.add{type="label", name="spacer", caption="   "}
        cb.style.size = {13, 13}
        cb.style.top_margin = 5
        this_flow.add{type="checkbox", name="mpr_player_toggle", tags={id=i}, caption=(i .. ": " .. player_names[i]), state=global.ignored_player_map[i]}
        local player_caption = ""
        if global.current_reversed_player_map[i] then
            player_caption = "(" .. game.get_player(global.current_reversed_player_map[i]).name .. ")"
        end
        this_flow.add{type="label", name="mpr_current_player", tags={id=i}, caption=player_caption}
    end
    local toggle_all_flow = player_flow.add{type="flow", name="mpr_player_toggle_all_flow", direction="horizontal"}
    toggle_all_flow.add{type="button", name="mpr_ignore_all_players", caption="Ignore All"}
    toggle_all_flow.add{type="button", name="mpr_activate_all_players", caption="Activate All"}
    for _, player in pairs(game.players) do

        for i=1,8 do
            local ocur = player.gui.screen.mpr_main_frame.mpr_main_flow.mpr_player_flow["mpr_player_flow_"..i].mpr_current_player
            if global.current_reversed_player_map[i] then
                ocur.caption = "(" .. game.get_player(global.current_reversed_player_map[i]).name .. ")"
            else
                ocur.caption = ""
            end
            
        end
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "pause" then
        game.tick_paused = true
    elseif event.element.name == "play" then
        game.speed = 1
        game.tick_paused = false
    elseif event.element.name == "fast" then
        game.speed = 8
        game.tick_paused = false
    elseif event.element.name == "fastest" then
        game.speed = 64
        game.tick_paused = false
    elseif event.element.name == "mpr_players_hide" then
        local player_global = global.players[event.player_index]
        player_global.players_visible = false

        event.element.visible = false
        event.element.parent["mpr_players_show"].visible = true
        event.element.parent.parent["mpr_player_flow"].visible = false
    elseif event.element.name == "mpr_players_show" then
        local player_global = global.players[event.player_index]
        player_global.players_visible = true

        event.element.visible = false
        event.element.parent["mpr_players_hide"].visible = true
        event.element.parent.parent["mpr_player_flow"].visible = true
    elseif event.element.name == "mpr_pause" then
        global.paused = event.element.state
        if global.paused then
            game.print(game.get_player(event.player_index).name .. " paused the bots")
        else
            game.print(game.get_player(event.player_index).name .. " unpaused the bots")
        end
        for _, player in pairs(game.players) do
            player.gui.screen.mpr_main_frame.mpr_main_flow.mpr_pause.state = event.element.state
        end
    elseif event.element.name == "mpr_player_toggle" then
        local player_id = event.element.tags.id
        toggle_ignore_player(player_id, event.element.state, event.element.parent.parent)
    elseif event.element.name == "mpr_player_set" then
        local player_flow = event.element.parent.parent
        local new_id = event.element.tags.id
        local current_id = global.current_player_map[event.player_index]
        if new_id == current_id then
            return
        end
        toggle_ignore_player(new_id, true, player_flow)
        if current_id then
            toggle_ignore_player(current_id, false, player_flow)
        end
        if global.current_reversed_player_map[new_id] then
            global.current_player_map[global.current_reversed_player_map[new_id]] = nil
        end
        global.current_player_map[event.player_index] = new_id
        if current_id then
            global.current_reversed_player_map[current_id] = nil
        end
        global.current_reversed_player_map[new_id] = event.player_index
        for _, player in pairs(game.players) do

            for i=1,8 do
                local ocur = player.gui.screen.mpr_main_frame.mpr_main_flow.mpr_player_flow["mpr_player_flow_"..i].mpr_current_player
                if global.current_reversed_player_map[i] then
                    ocur.caption = "(" .. game.get_player(global.current_reversed_player_map[i]).name .. ")"
                else
                    ocur.caption = ""
                end
                
            end
        end

    elseif event.element.name == "mpr_ignore_all_players" then
        for i=1,8 do
            toggle_ignore_player(i, true, event.element.parent.parent)
        end
    elseif event.element.name == "mpr_activate_all_players" then
        for i=1,8 do
            toggle_ignore_player(i, false, event.element.parent.parent)
        end
    elseif event.element.name == "mpr_speed_set" then
        global.speed = tonumber(event.element.parent["mpr_bot_speed"].text)
        game.print(game.get_player(event.player_index).name .. " set speed to " .. global.speed)
        for _, player in pairs(game.players) do
            player.gui.screen.mpr_main_frame.mpr_main_flow.mpr_controls_flow.mpr_bot_speed.text = event.element.parent["mpr_bot_speed"].text
        end
    end
end)

local is_module = function(item_name)
    return string.find(item_name, "-module")
 end

local player_dropped = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.entity_name, event.position)
    -- If they drop into something that doesn't exist, fine...
    if entity == nil then
        -- Handle two chests left of burner city being misplaced
        if not global.top_chest and global.tick < 10000 and event.entity_name == "wooden-chest"
                and event.position.x < 101 and event.position.x > 94
                and event.position.y < 7 and event.position.y > -3 and not global.top_chest then
            chests = game.surfaces[1].find_entities_filtered{area={{94, -3}, {101, 7}},
                type={'container'}}
            if #chests ~= 2 then
                if not global.warned_chests then
                    game.print("Expected exactly two chests next to burner city")
                    global.warned_chests = true
                end
            else
                if chests[1].position.y < chests[2].position.y then
                    global.top_chest = chests[1]
                    global.bottom_chest = chests[2]
                else
                    global.top_chest = chests[2]
                    global.bottom_chest = chests[1]
                end
            end
        end
        if global.top_chest and event.position.x == 98.5 then
            if event.position.y == .5 then
                entity = global.top_chest
            elseif event.position.y == 3.5 then
                entity = global.bottom_chest
            else
                return true
            end
        else
            return true
        end
    end
    if event.entity_name == "burner-mining-drill" or entity.type == "furnace" or event.entity_name == "boiler" then
        local inv = entity.get_inventory(defines.inventory.fuel)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "container" then
        local inv = entity.get_inventory(defines.inventory.chest)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "beacon" then
        local inv = entity.get_inventory(defines.inventory.beacon_modules)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "assembling-machine" then
        local inv_type = defines.inventory.assembling_machine_input
        if is_module(event.item_name) then
            local mod_inv = entity.get_inventory(defines.inventory.assembling_machine_modules)
            if mod_inv[1].valid_for_read and mod_inv[2].valid_for_read and event.item_name == mod_inv[1].name then
            elseif entity.get_recipe() and entity.get_recipe().name == "rocket-control-unit" then
            else
                inv_type = defines.inventory.assembling_machine_modules
            end
        end
        local inv = entity.get_inventory(inv_type)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "rocket-silo" then
        local inv_type = defines.inventory.assembling_machine_input
        if is_module(event.item_name) then
            inv_type = defines.inventory.assembling_machine_modules
        end
        local inv = entity.get_inventory(inv_type)
        inv.insert({name=event.item_name, count=event.count})
    elseif entity.type == "lab" then
        local inv_type = defines.inventory.lab_input
        if is_module(event.item_name) then
            inv_type = defines.inventory.lab_modules
        end
        local inv = entity.get_inventory(inv_type)
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
    if entity == nil or entity.name == event.item_name then
        if false and debug then
            game.print(player_names[event.player_index] .. " tried to take " .. event.count .. " " ..
                event.item_name .. " from a " .. event.entity_name .. " at " .. serpent.line(event.position) .. " but the entity didn't exist")
        end
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
        local removed = inv.remove({name=event.item_name, count=event.count})
        if removed < event.count then
            if false and debug then
                game.print(player_names[event.player_index] .. " tried to take " .. event.count .. " " ..
                    event.item_name .. " from a " .. event.entity_name .. " at " .. serpent.line(event.position) .. " but only got " .. removed)
            end
            event.count = event.count - removed
            return false
        end
    elseif entity.name == "burner-mining-drill" then
        local inv = entity.get_inventory(defines.inventory.fuel)
        local removed = inv.remove({name=event.item_name, count=event.count})
        if removed < event.count then
            if false and debug then
                game.print(player_names[event.player_index] .. " tried to take " .. event.count .. " " ..
                    event.item_name .. " from a " .. event.entity_name .. " at " .. serpent.line(event.position) .. " but only got " .. removed)
            end
            event.count = event.count - removed
            return false
        end
    elseif entity.type == "container" then
        local inv = entity.get_inventory(defines.inventory.chest)
        local removed = inv.remove({name=event.item_name, count=event.count})
        if removed < event.count then
            if false and debug then
                game.print(player_names[event.player_index] .. " tried to take " .. event.count .. " " ..
                    event.item_name .. " from a " .. event.entity_name .. " at " .. serpent.line(event.position) .. " but only got " .. removed)
            end
            event.count = event.count - removed
            return false
        end
        
    elseif entity.type == "lab" then
        local inv = entity.get_inventory(defines.inventory.assembling_machine_input)
        local removed = inv.remove({name=event.item_name, count=event.count})
        if removed < event.count then
            if false and debug then
                game.print(player_names[event.player_index] .. " tried to take " .. event.count .. " " ..
                    event.item_name .. " from a " .. event.entity_name .. " at " .. serpent.line(event.position) .. " but only got " .. removed)
            end
            event.count = event.count - removed
            return false
        end
    elseif entity.type == "simple-entity" or entity.type == "tree" then
    else
        if debug then
            game.print("take " .. event.entity_name)
        end
    end
    return true
end

local player_gave = function(event)
    -- If the giving player is a real player or the receiving player isn't a real player, do nothing.
    if global.current_reversed_player_map[event.player_index] or not global.current_reversed_player_map[event.to_player_index] then
        return true
    end
    local player = game.get_player(global.current_reversed_player_map[event.to_player_index])
    local count = player.get_main_inventory().insert({name=event.item_name, count=event.count})
    if count < event.count then
        player.print(player_names[event.player_index] .. " tried to give you " .. event.item_name .. " but your inventory was full")
    else
        player.print(player_names[event.player_index] .. " gave you " .. event.count .. " ".. event.item_name)
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
    if entity.type == "underground-belt" and event.belt_to_ground_type ~= entity.belt_to_ground_type then
        entity.rotate()
    else
        entity.direction = event.direction
    end
    return true
end

local set_recipe = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil then
        if debug then
            game.print("failed to set recipe " .. event.recipe .. " at " .. event.position)
        end
        return false
    end
    entity.set_recipe(event.recipe)
    return true
end

local set_splitter = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil then
        if debug then
            game.print("failed to set splitter at " .. event.position)
        end
        return false
    end
    if event.filter then
        entity.splitter_filter = game.item_prototypes[event.filter]
    end
    if event.splitter_input_priority then
        entity.splitter_input_priority = event.splitter_input_priority
    end
    if event.splitter_output_priority then
        entity.splitter_output_priority = event.splitter_output_priority
    end
    return true
end

local set_inserter_filter = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil then
        if debug then
            game.print("failed to set inserter filter at " .. event.position)
        end
        return false
    end
    if event.filter then
        entity.set_filter(2, event.filter)
    end
    return true
end

local build_entity = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity and entity.name == event.name and (not event.ghost_name or entity.ghost_name == event.ghost_name) then
        return true
    end
    local build_check_type = defines.build_check_type.manual
    if event.ghost_name then
        build_check_type = defines.build_check_type.manual_ghost
    end
    if event.name ~= "entity-ghost" and not game.surfaces["nauvis"].can_place_entity{
        name = event.name,
        position = event.position,
        direction = event.direction,
        force = "player",
        inner_name = event.ghost_name,
        build_check_type = build_check_type,
    } then
        return false
    end
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
    if entity and global.current_reversed_player_map[event.player_index] then
        local b = entity.selection_box
        script.register_on_entity_destroyed(entity)
        global.entity_highlights[entity.unit_number] = rendering.draw_rectangle{
            left_top=b.left_top,
            right_bottom=b.right_bottom,
            color={0,.1,0,.1},
            filled=true,
            surface=game.surfaces["nauvis"]}
    end
    return entity ~= nil
end

script.on_event(defines.events.on_entity_destroyed, function(event)
    if global.entity_highlights[event.unit_number] then
        rendering.destroy(global.entity_highlights[event.unit_number])
        global.entity_highlights[event.unit_number] = nil
    end
end)

local on_research_started = function(event)
    if global.ignored_player_map[5] then
        return true
    end
    return game.forces.player.add_research(event.name)
end

local on_player_changed_position = function(event)
    global.player_entities[event.player_index].teleport(event.position)
    global.player_entities[event.player_index].direction = event.direction
    return true
end

local totime = function(tick)
    hour = math.floor(tick / 3600 / 60)
    minute = math.floor(tick / 60 / 60) % 60
    second = math.floor(tick / 60) % 60
    return string.format("%d:%02d:%02d", hour, minute, second)
end

script.on_event(defines.events.on_tick, function(tick_event)
    for _, index in pairs(global.current_player_map) do
        if not global.ignored_player_map[index] then
            game.surfaces[1].daytime = 0
        end
    end
    if global.paused then
        return
    end
    if not global.real_last_tick then
        global.real_last_tick = -1
    end
    global.tick = global.tick + global.speed
    local new_tick = math.floor(global.tick)
    if global.tick_label then
        global.tick_label.caption = tostring(new_tick)
    end
    for _, player in pairs(game.players) do
        global.time_labels[player.index].caption = totime(new_tick)
    end
    for tick = global.last_tick+1,new_tick do
        if tick - 1 ~= global.real_last_tick then
            game.print("lost tick " .. tick - 1)
        end
        global.real_last_tick = tick
        if tick % 300 == 0 and #events_to_run > 0 then
            if debug then
                game.print(#events_to_run .. " events are failing to run")
            end
        end
        while global.mp_event_index <= #player_events and tick >= player_events[global.mp_event_index].tick do
            local ev = player_events[global.mp_event_index]
            if ev.event_type == "on_player_changed_position" then
                global.player_positions[ev.player_index] = ev.position
                global.player_directions[ev.player_index] = ev.direction
            end
            if not global.ignored_player_map[ev.player_index] then
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
                elseif event.event_type == "player_gave" then
                    noerr, success = pcall(player_gave, event)
                elseif event.event_type == "set_recipe" then
                    noerr, success = pcall(set_recipe, event)
                elseif event.event_type == "set_splitter" then
                    noerr, success = pcall(set_splitter, event)
                elseif event.event_type == "set_inserter_filter" then
                    noerr, success = pcall(set_inserter_filter, event)
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
                    if event.tick == tick and event.event_type == "on_player_mined_entity" then
                        if debug then
                            game.print("failed to execute event: " .. serpent.line(event))
                        end
                    end
                    -- Try again for up to 60 secs
                    if tick - event.tick < 60 * 60 then
                        table.insert(new_events_to_run, event)
                    end
                end
            end
        end
        events_to_run = new_events_to_run
    end
    global.last_tick = new_tick

end)