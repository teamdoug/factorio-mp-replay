local player_events = require("player_events")


-- For testing what's going wrong
local debug = false


local player_names = {
    'Franqly',
    'GlassBricks',
    'heartosis',
    'JeHor',
    'mysticamber',
    'Phredward',
    'thedoh',
    'thePiedPiper'
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

local misplaceable_chests = {
    heart_chest_1={built_tick=1191, end_tick=2000,
        x = -53.5, y = 90.5},
    heart_chest_2={built_tick=8909, end_tick=2000000,
        x = 223.5, y = 357.5},
    phred_chest_1={built_tick=4126, end_tick=2000000,
        x = 122.5, y = 4.5},
    jehor_chest_1={built_tick=4615, end_tick=2000000,
        x = 174.5, y = -64.5},
    doh_chest_1={built_tick=6206, end_tick=2000000,
        x = -0.5, y = 142.5},
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
            scale_with_zoom = true,
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
    global.track_players = false
    global.track_player_toggles = {}
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
    global.chests = {}
    global.events_to_run = {}
end)


local create_player = function(event)
    local player = game.get_player(event.player_index)
    if debug and player.name ~= "heartosis" then  
        debug = false
    end
    local extra_speed_control = player.name == "heartosis"
    local name = player.name:lower()
    if not global.players[event.player_index] then
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
    end

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
    global.track_player_toggles[event.player_index] = player_flow.add{type="checkbox", name="track_players_toggle", caption="Track all placements", state=global.track_players}
    for _, player in pairs(game.players) do

        for i=1,8 do
            if player.gui.screen.mpr_main_frame then
                local ocur = player.gui.screen.mpr_main_frame.mpr_main_flow.mpr_player_flow["mpr_player_flow_"..i].mpr_current_player
                if global.current_reversed_player_map[i] then
                    ocur.caption = "(" .. game.get_player(global.current_reversed_player_map[i]).name .. ")"
                else
                    ocur.caption = ""
                end
            end
        end
    end
end

script.on_configuration_changed(function(config_change)
    local old_version = config_change.mod_changes['mp-replay'].old_version
    if old_version == nil then
        return
    end
    local ver_nums = {}
    for v in old_version:gmatch("(%d+)") do
        table.insert(ver_nums, tonumber(v))
    end
    if ver_nums[1] == 0 and ver_nums[2] < 6 then
        global.track_players = false
        global.track_player_toggles = {}
    end
    if not global.time_labels then
        global.time_labels = {}
    end
    for index, player in pairs(game.players) do
        if player.gui.screen["mpr_main_frame"] then
            player.gui.screen.mpr_main_frame.destroy()
        end
        create_player({player_index = index})
    end
    if not global.chests then
        global.chests = {}
    end
end)

script.on_event(defines.events.on_player_created, create_player)


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
    elseif event.element.name == "track_players_toggle" then
        global.track_players = not global.track_players
        for _, toggle in pairs(global.track_player_toggles) do
            toggle.state = global.track_players
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

local is_in_misplaced_chest = function(x, y)
    -- Tick check?
    for chest_name, chest in pairs(misplaceable_chests) do
        if global.chests[chest_name] then
            if x == chest.x and y == chest.y then
                return global.chests[chest_name]
            end
        end
    end
    return nil
end

local is_misplaced_chest = function(x, y, event)
    -- Tick check?
    for chest_name, chest in pairs(misplaceable_chests) do
        if not global.chests[chest_name] then
            if x > chest.x - 7 and x < chest.x + 7 and y > chest.y - 7 and y < chest.y + 7 then
                local chests = game.surfaces[1].find_entities_filtered{area={{chest.x - 7, chest.y - 7}, {chest.x + 7, chest.y + 7}},
                    type={'container'}}
                if #chests ~= 1 then
                    if not global.warned_chests then
                        game.print("Missing chest near (" .. x .. ", " .. y .. ")")
                        global.warned_chests = true
                    end
                else
                    return {name=chest_name, entity=chests[1]}
                end
            end
        end
    end
    return nil
end     

local player_dropped = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.entity_name, event.position)
    -- Handle chests being misplaced
    if entity == nil and event.entity_name == "wooden-chest" then
        local chest = is_in_misplaced_chest(event.position.x, event.position.y)
        if chest ~= nil then
            entity = chest.entity
        else
            chest = is_misplaced_chest(event.position.x, event.position.y, event)
            if chest ~= nil then
                global.chests[chest.name] = {entity=chest.entity, x=chest.entity.position.x, y=chest.entity.position.y}
                entity = chest.entity
            else
                game.print(player_names[event.player_index] .. ' found no chest near (' .. x .. ", " .. y .. ")")
            end
        end
    end
    -- If they drop into something that doesn't exist, try again for a bit if it's a red science pack...
    if entity == nil then
        if event.item_name == 'automation-science-pack' then
            return false
        end
        return true
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
            elseif entity.get_recipe() and (entity.get_recipe().name == "rocket-control-unit" or is_module(entity.get_recipe().name)) then
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
    if entity == nil and event.entity_name == "wooden-chest" then
        local chest = is_in_misplaced_chest(event.position.x, event.position.y)
        if chest ~= nil then
            entity = chest.entity
        else
            chest = is_misplaced_chest(event.position.x, event.position.y, event)
            if chest ~= nil then
                global.chests[chest.name] = {entity=chest.entity, x=chest.entity.position.x, y=chest.entity.position.y}
                entity = chest.entity
            end
        end
    end
    -- If they take from something that doesn't exist, try again...
    -- or if they're picking up the entity (?)...
    if entity == nil or entity.name == event.item_name then
        if debug then
            game.print(player_names[event.player_index] .. " tried to take " .. event.count .. " " ..
                event.item_name .. " from a " .. event.entity_name .. " at " .. serpent.line(event.position) .. " but the entity didn't exist")
        end
        return false
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
        -- rocks and trees we don't care if something else killed them unless the chunk needs generating
        if event.type == "simple-entity" or event.type == "tree" then
            if not game.surfaces[1].is_chunk_generated({event.position.x / 32, event.position.y / 32}) then
                game.surfaces[1].request_to_generate_chunks(event.position, 0)
                return false
            end
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

local scale_color = function(color, alpha)
    return {color[1] * alpha, color[2] * alpha, color[3] * alpha, alpha}
end

local build_entity = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity and entity.name == event.name and (not event.ghost_name or entity.ghost_name == event.ghost_name) then
        if entity.type == "underground-belt" and event.belt_to_ground_type ~= entity.belt_to_ground_type then
            entity.rotate()
        elseif entity.direction ~= event.direction then
            entity.direction = event.direction
        end
        return true
    end
    local build_check_type = defines.build_check_type.manual
    local check_name = event.name
    if event.ghost_name then
        build_check_type = defines.build_check_type.manual_ghost
        check_name = event.ghost_name
    end
    if not game.surfaces["nauvis"].can_place_entity{
        name = check_name,
        position = event.position,
        direction = event.direction,
        force = "player",
        build_check_type = build_check_type,
    } then
        if not game.surfaces[1].is_chunk_generated({event.position.x / 32, event.position.y / 32}) then
            game.surfaces[1].request_to_generate_chunks(event.position, 0)
            return false
        end
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
    if entity and global.track_players then
        local b = entity.selection_box
        script.register_on_entity_destroyed(entity)
        global.entity_highlights[entity.unit_number] = rendering.draw_rectangle{
            left_top=b.left_top,
            right_bottom=b.right_bottom,
            color=scale_color(player_colors[event.player_index], 0.4),
            filled=true,
            surface=game.surfaces["nauvis"]}
    elseif entity and global.current_reversed_player_map[event.player_index] then
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
    if global.ignored_player_map[1] then
        return true
    end
    return game.forces.player.add_research(event.name)
end

local on_player_changed_position = function(event)
    global.player_entities[event.player_index].teleport(event.position)
    global.player_entities[event.player_index].direction = event.direction
    return true
end

local on_player_flushed_fluid = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil or entity.type ~= event.type then
        if debug then
            game.print("failed to flush fluid at " .. event.position)
        end
        -- Presumably players are only flushing their own fluids, so ignore it?
        return true
    end
    entity.fluidbox.flush(1, event.fluid)
    return true
end

local on_marked_for_deconstruction = function(event)
    local entity = game.surfaces["nauvis"].find_entity(event.name, event.position)
    if entity == nil or entity.type ~= event.type then
        if debug then
            game.print("failed to deconstruct entity at " .. event.position)
        end
        -- It's already deconstructed??
        return true
    end
    entity.order_deconstruction(game.forces.player)
    return true
end

local on_picked_up_item = function(event)

    -- player item_pickup_radius is 1
    local items = game.surfaces[1].find_entities_filtered{position=event.position, radius=1, name="item-on-ground"}
    if #items > 0 then
        for _, item in pairs(items) do
            if item.stack.name == event.item_stack.name then
                item.destroy()
                return true
            end
        end
    end
    -- use a larger radius since we might be grabbing from the near side
    local belts = game.surfaces[1].find_entities_filtered{position=event.position, radius=1.5, type="transport-belt"}
    -- We could use this info to target better, but we don't ^^
    -- Belt transport line 1 is left side looking at direction it's going
    -- position 0 is entrance, 1 is exit
    if #belts > 0 then
        for _, belt in pairs(belts) do
            if belt.get_item_count(event.item_stack.name) > 0 then 
                belt.remove_item({name=event.item_stack.name, count=100})
                return true
            end
        end
    end
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
    -- At tick 1 give each player 8 iron plate if they are the first player but aren't
    -- playing as jehor. If they aren't the first player but are playing as
    -- jehor, remove 8 iron plate.
    if global.tick >= 1 and global.real_last_tick < 1 then
        for index, player in pairs(game.players) do
            if index == 1 and global.current_player_map[index] ~= 4 then
                player.get_main_inventory().insert({name="iron-plate", count=8})
            end
            if index ~= 1 and global.current_player_map[index] == 4 then
                player.get_main_inventory().remove({name="iron-plate", count=8})
            end
        end
    end
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
        if tick % 300 == 0 and #global.events_to_run > 0 then
            if debug then
                game.print(#global.events_to_run .. " events are failing to run")
            end
        end
        while global.mp_event_index <= #player_events and tick >= player_events[global.mp_event_index].tick do
            local ev = player_events[global.mp_event_index]
            if ev.event_type == "on_player_changed_position" then
                global.player_positions[ev.player_index] = ev.position
                global.player_directions[ev.player_index] = ev.direction
            end
            if not global.ignored_player_map[ev.player_index] then
                table.insert(global.events_to_run, ev)
            end
            global.mp_event_index = global.mp_event_index + 1
        end
        local new_events_to_run = {}
        for _, event in ipairs(global.events_to_run) do
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
                elseif event.event_type == "on_player_flushed_fluid" then
                    noerr, success = pcall(on_player_flushed_fluid, event)
                elseif event.event_type == "on_marked_for_deconstruction" then
                    noerr, success = pcall(on_marked_for_deconstruction, event)
                elseif event.event_type == "on_picked_up_item" then
                    noerr, success = pcall(on_picked_up_item, event)
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
                    -- Try again for up to 60 secs or 5 min if it's an automation science pack
                    if tick - event.tick < 60 * 60 or (event.item_name == 'automation-science-pack' and tick - event.tick < 5 * 60 * 60) then
                        table.insert(new_events_to_run, event)
                    end
                end
            end
        end
        global.events_to_run = new_events_to_run
    end
    global.last_tick = new_tick

end)