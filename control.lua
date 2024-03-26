local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

local generate_crafting_queues = false

local player_cursor_stacks = {}
local player_inventories = {
    [1] = {["burner-mining-drill"] = 1, ["stone-furnace"] = 1, wood = 1}
}
local player_selected_entities = {}
local player_hand_locations = {}
local last_moved = {[1] = 0}
local last_position = {[1] = {0, 0}}
local crafting_queues = {}
local walking_states = {}
for i=1,8 do
    crafting_queues[i] = {}
    walking_states[i] = {}
end

local prev_entity_contents = {}


local debug_player = 0

-- The order players are in your planning docs.
-- Needs to match mp-replay/control.lua's player_names.
local player_names = {
    'JeHor',
    'Phredward',
    'heartosis',
    'Franqly',
    'GlassBricks',
    'thePiedPiper',
    'thedoh',
    'NapoleonBonerfart',
}

-- The order of players in the replay. Names don't need to match player_names.
local player_mapping = {
    'JeHor',
    'Phredward',
    'thePiedPiper',
    'GlassBricks',
    'thedoh',
    'heartosis',
    'Franqly',
    'NapoleonBonerfart',
}

local reverse_player_names = {}
for i, name in ipairs(player_names) do
	reverse_player_names[name] = i
end

-- checking for spelling mistakes between player_names and player_mapping
for _, name in ipairs(player_mapping) do
    if reverse_player_names[name] == nil then
        error("Spelling error in player_names or player_mapping for " .. name)
    end
end

-- Entities we set recipes on. Yeesh. I guess entity.type isn't set on bps?
local assembler_entities = {
    ["assembling-machine-1"] = true,
    ["assembling-machine-2"] = true,
    ["chemical-plant"] = true,
    ["oil-refinery"] = true,
}
-- Entities we set bars on. Yeesh.
local container_entities = {
    ["iron-chest"] = true,
    ["wooden-chest"] = true,
    ["steel-chest"] = true,
}
local splitter_entities = {
    ["splitter"] = true,
}
-- Entities we set filters on.
local filter_entities = {
    ["filter-inserter"]= true,
}

local player_bps = {}

local message_buffer = {}
local next_log_tick = 0
local p2

local function slog(ltable)
    if ltable.player_index then
        ltable.player_index = reverse_player_names[player_mapping[ltable.player_index]]
    end
    if ltable.to_player_index then
        ltable.to_player_index = reverse_player_names[player_mapping[ltable.to_player_index]]
    end
    table.insert(message_buffer, serpent.line(ltable))
    if #message_buffer >= 50 then
    --if #message_buffer >= 1 then
        log("rlog: " .. table.concat(message_buffer, "\nrlog: "))
        message_buffer = {}
    end
end

for i = 2,8 do
    player_inventories[i] = {["burner-mining-drill"] = 1, ["stone-furnace"] = 1, wood = 1, ["iron-plate"] = 8}
    last_moved[i] = 0
    last_position[i] = {0, 0}
end

script.on_event(defines.events.on_pre_ghost_deconstructed,
    function(event)
        slog({event_type="on_player_mined_entity",
        tick=event.tick,
        player_index=event.player_index,
        position=event.ghost.position,
        name=event.ghost.name,
        type=event.ghost.type})
        
    end
)

script.on_event(defines.events.on_player_mined_entity,
    function(event)
        slog({event_type="on_player_mined_entity",
        tick=event.tick,
        player_index=event.player_index,
        position=event.entity.position,
        name=event.entity.name,
        type=event.entity.type})
        
    end
)

last_underground_belt_entity = nil
last_underground_belt_entity_direction = nil

script.on_event(defines.events.on_built_entity,
    function(event)
        local ce = event.created_entity
        local e = {event_type="on_built_entity",
        tick=event.tick,
        player_index=event.player_index,
        position=ce.position,
        name=ce.name,
        type=ce.type,
        direction=ce.direction}
        local type = ce.type
        if ce.type == "entity-ghost" then
            e.ghost_name = ce.ghost_name
            type = ce.ghost_type
            if type == "inserter" and ce.filter_slot_count > 0 and ce.get_filter(1) ~= nil then
                e.filter = ce.get_filter(1)
            end
        end
        if type == "underground-belt" then
            e.belt_to_ground_type = ce.belt_to_ground_type
            last_underground_belt_entity = ce
            last_underground_belt_entity_direction = ce.belt_to_ground_type
        elseif type == "assembling-machine" then
            if ce.get_recipe() then
                e.recipe = ce.get_recipe().name
            end
        elseif type == "container" then
            local inv = ce.get_inventory(defines.inventory.chest)
            if inv then
                e.bar = inv.get_bar()
            end
        elseif type == "item-entity" then
            e.stack = event.stack
        end
        slog(e)
        for i=1,8 do
            if player_bps[i] then
                local bp = player_bps[i]
                if bp.have_entities and bp.have_entities[ce.name] then
                    local j = #bp.entities+1
                    bp.entities[j] = ce
                    if ce.type == "assembling-machine" then
                        bp.orig_recipes[j] = ce.get_recipe() and ce.get_recipe().name
                        bp.orig_directions[j] = ce.direction
                    end
                    if bar and ce.type == "container" then
                        bp.orig_bars[j] = ce.get_inventory(defines.inventory.chest).get_bar()
                    end
                    if ce.get_filter(1) ~= nil then
                        bp.orig_filters[j] = {
                            filter = ce.get_filter(1),
                        }
                    end
                end
            end
        end
    end
)

script.on_event(defines.events.on_research_started,
    function(event)
        slog({event_type="on_research_started",
        tick=event.tick,
        name=event.research.name})
        
    end
)

script.on_event(defines.events.on_player_mined_entity,
    function(event)
        slog({event_type="on_player_mined_entity",
        tick=event.tick,
        player_index=event.player_index,
        position=event.entity.position,
        name=event.entity.name,
        type=event.entity.type})
        
    end
)

script.on_event(defines.events.on_player_rotated_entity,
    function(event)
        local belt_to_ground_type
        if event.entity.type == "underground-belt" then
            belt_to_ground_type = event.entity.belt_to_ground_type
        end
        slog({event_type="on_player_rotated_entity",
        tick=event.tick,
        player_index=event.player_index,
        position=event.entity.position,
        direction=event.entity.direction,
        belt_to_ground_type=belt_to_ground_type,
        name=event.entity.name,
        type=event.entity.type})
    end
)

local bars = {}

script.on_event(defines.events.on_gui_opened,
    function(event)
        if event.gui_type ~= defines.gui_type.entity then
            return
        end
        if event.entity.type == "container" then
            local inv = event.entity.get_inventory(defines.inventory.chest)
            bars[event.entity.unit_number] = inv.get_bar()
        end
    end
)

script.on_event(defines.events.on_gui_closed,
function(event)
    if event.gui_type == defines.gui_type.entity then
        if event.entity.type == "assembling-machine" then
            local recipe = event.entity.get_recipe()
            slog({event_type="set_recipe",
            tick=event.tick,
            player_index=event.player_index,
            position=event.entity.position,
            name=event.entity.name,
            type=event.entity.type,
            recipe=recipe and recipe.name})
        elseif event.entity.type == "splitter" then
            local filter = event.entity.splitter_filter
            slog({event_type="set_splitter",
            tick=event.tick,
            player_index=event.player_index,
            position=event.entity.position,
            name=event.entity.name,
            type=event.entity.type,
            filter=filter and filter.name,
            splitter_input_priority=event.entity.splitter_input_priority,
            splitter_output_priority=event.entity.splitter_output_priority})
        elseif event.entity.name == "filter-inserter" then
            local filter = event.entity.get_filter(1)
            if filter == nil then
                filter = event.entity.get_filter(2)
            end
            slog({event_type="set_inserter_filter",
            tick=event.tick,
            player_index=event.player_index,
            position=event.entity.position,
            name=event.entity.name,
            type=event.entity.type,
            filter=filter})
        elseif event.entity.type == "container" then
            local inv = event.entity.get_inventory(defines.inventory.chest)
            if bars[event.entity.unit_number] ~= inv.get_bar() then
                bars[event.entity.unit_number] = inv.get_bar()
                slog({event_type="set_bar",
                    tick=event.tick,
                    player_index=event.player_index,
                    position=event.entity.position,
                    name=event.entity.name,
                    type=event.entity.type,
                    bar=inv.get_bar(),
                })
            end
        end
    end
end
)


local emit_drop = function(event, entity, name, count)
    slog({event_type="player_dropped",
        tick=event.tick,
        player_index=event.player_index,
        position=entity.position,
        entity_name=entity.name,
        item_name=name,
        count=count,
    })
end

local emit_take = function(event, entity, name, count)
    slog({event_type="player_took",
        tick=event.tick,
        player_index=event.player_index,
        position=entity.position,
        entity_name=entity.name,
        item_name=name,
        count=count,
    })
end

script.on_event(defines.events.on_tick, function(event)
    -- Maybe call find_entities_filtered every few seconds and keep entity references around?
    --[[
    local p = game.create_profiler(true)
    local p2 = game.create_profiler()
    local next = next
    local entity_contents = {}
    for i=1,8 do
        local player = game.get_player(i)
        if player then
            -- 12 is big enough for assemblers but not refineries
            p.restart()
            local position = player.position
            local radius = 12
            if player.selected then
                position = player.selected.position
                radius = 6
            end
            local entities = game.surfaces[1].find_entities_filtered{position=position, radius=radius, type={'container', 'furnace', 'assembling-machine'}}
            p.stop()
            for _, entity in ipairs(entities) do
                local inventories = {}
                if entity.type == 'container' then
                    local c = entity.get_inventory(defines.inventory.chest).get_contents()
                    if next(c) then
                        if not entity.unit_number then
                            log('empty entity: ' .. entity.name)
                        end
                        --entity_contents[entity.unit_number] = {chest = c, name = entity.name}
                    end
                elseif entity.type == 'furnace' then
                    local c = entity.get_inventory(defines.inventory.furnace_result).get_contents()
                    if next(c) then
                        inventories['furnace_result'] = c
                    end
                    --if inventories['furnace_source'] = entity.get_inventory(defines.inventory.furnace_source).get_contents()
                    c = entity.get_inventory(defines.inventory.fuel).get_contents()
                    if next(c) then
                        inventories['fuel'] = c
                    end
                    if next(inventories) then
                        if not entity.unit_number then
                            log('empty entity: ' .. entity.name)
                        end
                        inventories['name'] = entity.name
                        --entity_contents[entity.unit_number] = inventories
                    end
                    -- ehn furnace modules
                elseif entity.type == 'assembling-machine' then
                    local c = entity.get_inventory(defines.inventory.assembling_machine_output).get_contents()
                    if next(c) then
                        inventories['assembling_machine_output'] = c
                    end
                    c = entity.get_inventory(defines.inventory.assembling_machine_input).get_contents()
                    if next(c) then
                        inventories['assembling_machine_input'] = c
                    end
                    if next(inventories) then
                        if not entity.unit_number then
                            log('empty entity: ' .. entity.name)
                        end
                        inventories['name'] = entity.name
                        --entity_contents[entity.unit_number] = inventories
                    end
                    --inventories['assembling_machine_modules'] = entity.get_inventory(defines.inventory.assembling_machine_modules).get_contents()
                end
            end
        end
    end
    if event.tick % 60 == 0 then
        slog({event_type="entity_contents", entity_contents=entity_contents})
    end
    prev_entity_contents = entity_contents
    log(p)
    log(p2)
    ]]
    --[[
    local next = next
    if event.tick % 60 == 0 then
        local entity_contents = {}
        local entities = game.surfaces[1].find_entities_filtered{type={'container', 'furnace', 'assembling-machine'}}
        for _, entity in ipairs(entities) do
            local inventories = {}
            if entity.type == 'container' then
                local c = entity.get_inventory(defines.inventory.chest).get_contents()
                if next(c) then
                    entity_contents[entity.unit_number] = {chest = c}
                elseif entity_contents[entity.unit_number] then
                    entity_contents[entity.unit_number] = nil
                end
            elseif entity.type == 'furnace' then
                local c = entity.get_inventory(defines.inventory.furnace_result).get_contents()
                if next(c) then
                    inventories['furnace_result'] = c
                end
                --if inventories['furnace_source'] = entity.get_inventory(defines.inventory.furnace_source).get_contents()
                c = entity.get_inventory(defines.inventory.fuel).get_contents()
                if next(c) then
                    inventories['fuel'] = c
                end
                if next(inventories) then
                    entity_contents[entity.unit_number] = inventories
                elseif entity_contents[entity.unit_number] then
                    entity_contents[entity.unit_number] = nil
                end
                -- ehn furnace modules
            elseif entity.type == 'assembling-machine' then
                local c = entity.get_inventory(defines.inventory.assembling_machine_output).get_contents()
                if next(c) then
                    inventories['assembling_machine_output'] = c
                end
                c = entity.get_inventory(defines.inventory.assembling_machine_input).get_contents()
                if next(c) then
                    inventories['assembling_machine_input'] = c
                end
                if next(inventories) then
                    entity_contents[entity.unit_number] = inventories
                elseif entity_contents[entity.unit_number] then
                    entity_contents[entity.unit_number] = nil
                end
                --inventories['assembling_machine_modules'] = entity.get_inventory(defines.inventory.assembling_machine_modules).get_contents()
            end
        end

        slog({event_type="entity_contents", entity_contents=entity_contents})
    end
    ]]
    if last_underground_belt_entity ~= nil then
        if last_underground_belt_entity.belt_to_ground_type ~= last_underground_belt_entity_direction then
            local entity = last_underground_belt_entity
            slog({event_type="on_player_rotated_entity",
            tick=event.tick,
            player_index=entity.last_user.index,
            position=entity.position,
            direction=entity.direction,
            belt_to_ground_type=entity.belt_to_ground_type,
            name=entity.name,
            type=entity.type})
        end
        last_underground_belt_entity = nil
    end
    for i = 1,8 do
        local player = game.get_player(i)
        -- Rate limit position updates to twice a second
        if player and player.character and event.tick > last_moved[i] + 30 then
            if last_position[i][1] ~= player.position.x or last_position[i][2] ~= player.position.y then 
                --local p2 = game.create_profiler()
                slog({event_type="on_player_changed_position",
                    tick=event.tick,
                    player_index=i,
                    position=player.position,
                    direction=player.character.direction,
                })
                last_moved[i] = event.tick
                last_position[i] = player.position
            end
        end
        if player and player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.type == 'blueprint' then
            local entity_names = {}
            if not player_bps[i] or player_bps[i].item_number ~= player.cursor_stack.item_number then
                local have_entities = {}
                local have_recipes = {}
                local bar
                local bp_entities = player.cursor_stack.get_blueprint_entities()
                local splitter_setting
                if not bp_entities then
                    bp_entities = {}
                end
                for _, entity in ipairs(bp_entities) do
                    if assembler_entities[entity.name] then
                        if entity.recipe then
                            have_recipes[entity.recipe] = true
                        end
                        have_entities[entity.name] = entity.name
                    elseif container_entities[entity.name] then
                        if bar and entity.bar and bar ~= entity.bar then
                            game.print("bar was " .. bar .. " but have bar " .. entity.bar .. " for player " .. player.name)
                        end
                        if entity.bar then
                            bar = entity.bar
                        end
                        have_entities[entity.name] = entity.name
                    elseif splitter_entities[entity.name] then
                        have_entities[entity.name] = entity.name
                        -- Alas, splitter properties don't exist on bp entites, so assume any changes are us ;;
                        --[[
                        local new_splitter_setting = {
                            splitter_input_priority = entity.splitter_input_priority,
                            splitter_output_priority = entity.splitter_output_priority,
                        }
                        if entity.splitter_filter then
                            new_splitter_setting.splitter_filter = entity.splitter_filter.name
                        end
                        if splitter_setting and (
                            splitter_setting.splitter_input_priority ~= new_splitter_setting.splitter_input_priority
                            or splitter_setting.splitter_output_priority ~= new_splitter_setting.splitter_output_priority
                            or splitter_setting.splitter_filter ~= new_splitter_setting.splitter_filter
                        )  then
                            game.print('Multiple splitter settings in BP for player ' .. player.name .. ': '
                                .. serpent.line(splitter_seting) .. ' vs ' .. serpent.line(new_splitter_setting))
                        end
                        splitter_setting = new_splitter_setting
                        game.print('spltiter setting' .. serpent.line(new_splitter_setting))
                        game.print('spltiter setting' .. serpent.line(entity.splitter_input_priority))
                        for name, val in pairs(entity) do
                            game.print(name .. ': ' .. serpent.line(val))
                        end
                        ]]
                    elseif filter_entities[entity.name] then
                        have_entities[entity.name] = entity.name
                    end
                end
                if next(have_entities) then
                    local entities = game.surfaces[1].find_entities_filtered{name=have_entities}
                    local orig_recipes = {}
                    local orig_bars = {}
                    local orig_directions = {}
                    local orig_splitters = {}
                    local orig_filters = {}
                    for j, entity in ipairs(entities) do
                        if entity.type == "assembling-machine" then
                            orig_recipes[j] = entity.get_recipe() and entity.get_recipe().name
                            orig_directions[j] = entity.direction
                        end
                        if bar and entity.type == "container" then
                            orig_bars[j] = entity.get_inventory(defines.inventory.chest).get_bar()
                        end
                        if entity.type == "splitter" then
                            orig_splitters[j] = {
                                splitter_input_priority = entity.splitter_input_priority,
                                splitter_output_priority = entity.splitter_output_priority,
                            }
                            if entity.splitter_filter then
                                orig_splitters[j].splitter_filter = entity.splitter_filter.name
                            end
                        end
                        if entity.name == "filter-inserter" then
                            -- Only track the first filter slot
                            orig_filters[j] = {
                                filter = entity.get_filter(1),
                            }
                        end
                    end
                    player_bps[i] = {entities = entities, item_number = player.cursor_stack.item_number, bar = bar, splitter_setting = splitter_setting,
                        have_recipes = have_recipes, have_entities = have_entities, orig_bars = orig_bars, orig_recipes = orig_recipes,
                        orig_directions = orig_directions, orig_splitters = orig_splitters, orig_filters = orig_filters}
                    --log("bp")
                    --log(serpent.line(player_bps[i]))
                else
                    player_bps[i] = {entities = {}}
                end
            end
            local bp = player_bps[i]
            -- Ideally, we would track others' known changes to ignore them here...
            for j, entity in ipairs(bp.entities) do
                if not entity.valid then
                elseif entity.type == "assembling-machine" then
                    local recipe = entity.get_recipe()
                    if recipe and bp.orig_recipes[j] ~= recipe.name and bp.have_recipes[recipe.name] then
                        slog({event_type="set_recipe",
                            tick=event.tick,
                            player_index=i,
                            position=entity.position,
                            name=entity.name,
                            type=entity.type,
                            recipe=recipe.name,
                        })
                        bp.orig_recipes[j] = recipe.name
                    end
                    if recipe and bp.have_recipes[recipe.name] and entity.direction ~= bp.orig_directions[j] then
                        slog({event_type="on_player_rotated_entity",
                            tick=event.tick,
                            player_index=i,
                            position=entity.position,
                            name=entity.name,
                            type=entity.type,
                            direction=entity.direction,
                        })
                        bp.orig_directions[j] = entity.direction
                    end
                elseif entity.type == "container" and bp.bar then
                    local bar = entity.get_inventory(defines.inventory.chest).get_bar()
                    -- logic completely untested
                    if bar ~= bp.orig_bars[j] and bar ~= bp.bar then
                        --[[slog({event_type="set_bar",
                            tick=event.tick,
                            player_index=i,
                            position=entity.position,
                            name=entity.name,
                            type=entity.type,
                            recipe=recipe.name,
                        })]]
                    end
                -- I don't know how bp.orig_splitters[j] can be nil, but it can...
                elseif entity.type == "splitter" and bp.orig_splitters[j] then
                    local filter
                    if entity.splitter_filter then
                        filter = entity.splitter_filter.name
                    end
                    if (
                        bp.orig_splitters[j].splitter_input_priority ~= entity.splitter_input_priority
                        or bp.orig_splitters[j].splitter_output_priority ~= entity.splitter_output_priority
                        or bp.orig_splitters[j].splitter_filter ~= filter
                    ) then
                        -- Should check that new settings match the bp settings, but we don't have that...
                        slog({event_type="set_splitter",
                            tick=event.tick,
                            player_index=i,
                            position=entity.position,
                            name=entity.name,
                            type=entity.type,
                            filter=filter,
                            splitter_input_priority=entity.splitter_input_priority,
                            splitter_output_priority=entity.splitter_output_priority
                        })
                        bp.orig_splitters[j] = {
                            splitter_input_priority = entity.splitter_input_priority,
                            splitter_output_priority = entity.splitter_output_priority,
                            splitter_filter = filter,
                        }
                    end
                elseif entity.name == "filter-inserter" and bp.orig_filters[j] then
                    local filter = entity.get_filter(1)
                    if bp.orig_filters[j].filter ~= filter then
                        slog({event_type="set_inserter_filter",
                        tick=event.tick,
                        player_index=i,
                        position=entity.position,
                        name=entity.name,
                        type=entity.type,
                        filter=filter})
                        bp.orig_filters[j] = {
                            filter = filter
                        }
                    end
                end
            end
        elseif player_bps[i] then
            player_bps[i] = nil
        end
    end
    if event.tick >= next_log_tick then
        --if not p2 then
            --p2 = game.create_profiler()
        --end
        next_log_tick = event.tick + 600
        --log(p2)
        --p2.reset()
    end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
    if event.source.type == "assembling-machine" then
        local recipe = event.source.get_recipe()
        slog({event_type="set_recipe",
            tick=event.tick,
            player_index=event.player_index,
            position=event.destination.position,
            name=event.destination.name,
            type=event.destination.type,
            recipe=recipe and recipe.name
        }) 
    elseif event.source.type == "splitter" then
        local filter = event.destination.splitter_filter
        slog({event_type="set_splitter",
            tick=event.tick,
            player_index=event.player_index,
            position=event.destination.position,
            name=event.destination.name,
            type=event.destination.type,
            filter=filter and filter.name,
            splitter_input_priority=event.destination.splitter_input_priority,
            splitter_output_priority=event.destination.splitter_output_priority})
    elseif event.source.name == "filter-inserter" then
        local filter = event.destination.get_filter(1)
        if filter == nil then
            filter = event.destination.get_filter(2)
        end
        slog({event_type="set_inserter_filter",
        tick=event.tick,
        player_index=event.player_index,
        position=event.destination.position,
        name=event.destination.name,
        type=event.destination.type,
        filter=filter})
    end
end)


script.on_event(defines.events.on_player_crafted_item,
    function(event)
        local player = game.get_player(event.player_index)
        if player.crafting_queue[1].prerequisite then
            return
        end
        if generate_crafting_queues then
            local real_craft = player.crafting_queue[1]
            local crafting_queue = crafting_queues[event.player_index]
            if crafting_queue[1].recipe ~= player.crafting_queue[1].recipe then
                game.print('On craft, unexpectedly have craft for ' .. crafting_queue[1].recipe .. ' instead of ' .. real_craft.recipe .. ' for ' .. game.players[event.player_index].name)
            end
            
            crafting_queue[1].count = crafting_queue[1].count - 1
            if crafting_queue[1].count == 0 then
                table.remove(crafting_queue, 1)
            end

        end
        if event.player_index == debug_player then
            log(event.tick .. " craft " .. event.item_stack.count .. " " .. event.item_stack.name)
        end
        local inv = player_inventories[event.player_index]
        if not inv[event.item_stack.name] then
            inv[event.item_stack.name] = event.item_stack.count
        else
            inv[event.item_stack.name] = inv[event.item_stack.name] + event.item_stack.count
        end
    end
)

script.on_event(defines.events.on_pre_player_crafted_item,
    function(event)

        local inv = player_inventories[event.player_index]
        local curs = player_cursor_stacks[event.player_index]

        if generate_crafting_queues then
            local products = event.recipe.products
            if #products > 1 then
                game.print('Recipe with multiple products: ' .. event.recipe.name)
            end
            slog({event_type="on_pre_player_crafted_item", tick=event.tick, player_index=event.player_index,
                queued_count=event.queued_count, product=products[1].name, amount=products[1].amount})
            local real_crafting_queue = game.players[event.player_index].crafting_queue
            local crafting_queue = crafting_queues[event.player_index]
            local last_craft = real_crafting_queue[#real_crafting_queue]
            if #crafting_queue > 0 and crafting_queue[#crafting_queue].recipe == event.recipe.name then
                crafting_queue[#crafting_queue].count = crafting_queue[#crafting_queue].count + event.queued_count
            else
                table.insert(crafting_queue, {recipe=event.recipe.name, product=event.recipe.products[1].name, count=event.queued_count})
            end
            --reconcile_crafting_queues(event, crafting_queue, real_crafting_queue, true)
        end

        for i = 1,#event.items do
            local stack = event.items[i]
            if event.player_index == debug_player then
                log(event.tick .. " used " .. stack.count .. " " .. stack.name)
            end
            local left = stack.count
            if inv[stack.name] then
                if inv[stack.name] > stack.count then
                    inv[stack.name] = inv[stack.name] - stack.count
                    left = 0
                else
                    left = stack.count - inv[stack.name]
                    inv[stack.name] = nil
                end 
            end
            if left > 0 and curs and curs.name == stack.name then
                if curs.count < left then                    
                    left = left - curs.count
                    player_cursor_stacks[event.player_index] = nil
                else
                    curs.count = curs.count - left
                    left = 0
                end
            end
            if left > 0 then
                game.print(game.get_player(event.player_index).name .. " tried crafting " ..
                    event.recipe.name .. " but was missing " .. left .. " ".. stack.name)
            end
        end
    end
)

function reconcile_crafting_queues(event, crafting_queue, real_crafting_queue, expect_same)

    if expect_same then
        -- full inventories boo
        return
    end
    
    local abr_real_queue = {}
    for _, real_craft in pairs(real_crafting_queue) do
        if not real_craft.prerequisite then
            if #abr_real_queue > 0 and abr_real_queue[#abr_real_queue].recipe == real_craft.recipe then
                abr_real_queue[#abr_real_queue].count = abr_real_queue[#abr_real_queue].count + real_craft.count
            else
                table.insert(abr_real_queue, real_craft)
            end
        end
    end
    if expect_same then
        if #abr_real_queue ~= #crafting_queue then
            game.print('Not same')
            dump_queue(event, abr_real_queue, crafting_queue)
            return
        end
        for i, real_craft in pairs(abr_real_queue) do
            local craft = crafting_queue[i]
            if craft.recipe ~= real_craft.recipe or craft.count ~= real_craft.count then
                game.print('Not same')
                dump_queue(event, abr_real_queue, crafting_queue)
                return
            end
        end
        return
    end

    if #abr_real_queue < #crafting_queue - 1 then
        game.print('Cable cancel hit two different outputs?')
        return
    end
    if #abr_real_queue == #crafting_queue then
        for i, real_craft in pairs(abr_real_queue) do
            local craft = crafting_queue[i]
            if craft.count ~= real_craft.count and craft.recipe == real_craft.recipe then
                if real_craft.count < craft.count then
                    slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
                        cancel_count=(craft.count - real_craft.count), product=craft.product})
                    craft.count = real_craft.count
                    return reconcile_crafting_queues(event, crafting_queue, abr_real_queue, true)
                else
                    -- Full inventory probably
                    game.print('Gained item during cancel?')
                    dump_queue(event, abr_real_queue, crafting_queue)                
                end
            end
        end
        for i, real_craft in pairs(abr_real_queue) do
            local craft = crafting_queue[i]
            if craft.count ~= real_craft.count then
                if real_craft.count < craft.count then
                    slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
                        cancel_count=(craft.count - real_craft.count), product=craft.product})
                    craft.count = real_craft.count
                    return reconcile_crafting_queues(event, crafting_queue, abr_real_queue, true)
                else
                    -- Full inventory probably
                    game.print('Gained item during cancel?')
                    dump_queue(event, abr_real_queue, crafting_queue)                
                end
            end
        end
    else
        for i, real_craft in pairs(abr_real_queue) do
            local craft = crafting_queue[i]
            if craft.recipe ~= real_craft.recipe then
                table.remove(crafting_queue, i)
                slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
                    cancel_count=craft.count, product=craft.product})
                return reconcile_crafting_queues(event, crafting_queue, abr_real_queue, true)
            end
            if craft.count ~= real_craft.count then
                if real_craft.count < craft.count then
                    slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
                        cancel_count=(craft.count - real_craft.count), product=craft.product})
                    craft.count = real_craft.count
                    return reconcile_crafting_queues(event, crafting_queue, abr_real_queue, true)
                end
                table.remove(crafting_queue, i)
                slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
                    cancel_count=craft.count, product=craft.product})
                return reconcile_crafting_queues(event, crafting_queue, abr_real_queue, true)
            end
        end
        local craft = crafting_queue[#crafting_queue]
        table.remove(crafting_queue, #crafting_queue)
        slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
            cancel_count=craft.count, product=craft.product})
        return reconcile_crafting_queues(event, crafting_queue, abr_real_queue, true)
    end

    game.print('Couldn\'t find canceled craft')
    dump_queue(event, abr_real_queue, crafting_queue)
end

function dump_queue(event, real_crafting_queue, crafting_queue)
    if event.name == defines.events.on_player_cancelled_crafting then
        game.print('Error in cancel of ' .. event.cancel_count .. ' ' .. event.recipe.name .. ' for ' .. game.players[event.player_index].name)
    elseif event.name == defines.events.on_pre_player_crafted_item then
        game.print('Error in queueing of ' .. event.queued_count .. ' ' .. event.recipe.name .. ' for ' .. game.players[event.player_index].name)
    else
        game.print('Error in crafting of ' .. event.recipe.name .. ' for ' .. game.players[event.player_index].name)
    end
    for i, real_craft in pairs(real_crafting_queue) do
        if not real_craft.prerequisite then
            game.print('Real ' .. i .. ': ' .. real_craft.count .. ' ' .. real_craft.recipe)
        end
    end
    for i, craft in pairs(crafting_queue) do
        game.print('Simulated ' .. i .. ': ' .. craft.count .. ' ' .. craft.recipe)
    end
end

script.on_event(defines.events.on_player_cancelled_crafting,
    function(event)
        if not generate_crafting_queues then
            return
        end
        local products = event.recipe.products
        local crafting_queue = crafting_queues[event.player_index]
        local real_crafting_queue = game.players[event.player_index].crafting_queue
        --slog({event_type="raw_on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
            --cancel_count=event.cancel_count, product=event.recipe.products[1].name})
        if real_crafting_queue == nil then
            if #crafting_queue ~= 1 then
                game.print('expected one item in queue instead of ' .. #crafting_queue .. ' for ' .. game.players[event.player_index].name)
            end
            local craft = crafting_queue[1]
            slog({event_type="on_player_cancelled_crafting", tick=event.tick, player_index=event.player_index,
                cancel_count=craft.count, product=craft.product})
            table.remove(crafting_queue)
            return
        end
        reconcile_crafting_queues(event, crafting_queue, real_crafting_queue, false)
    end
)

script.on_event({defines.events.on_player_main_inventory_changed, defines.events.on_player_cursor_stack_changed, defines.events.on_player_fast_transferred},
function(event)
    --if event.tick == 247 then
      --  game.print(serpent.line(event))
    --end
    -- we could actually use the info on fast transfer events...
    local old_inv = player_inventories[event.player_index]
    local player = game.get_player(event.player_index)
    local cur_inv = player.get_main_inventory()
    cur_inv = cur_inv.get_contents()
    local new_inv_items = {}
    local lost_inv_items = {}
    --game.print(serpent.line(event))
    if event.player_index == debug_player then
        log("old_inv " .. serpent.line(old_inv))
    end

    old_hand = player_hand_locations[event.player_index]
    cur_hand = nil
    if player.hand_location and player.hand_location.inventory == defines.inventory.character_main then
        cur_hand = player.hand_location.slot
    end
    player_hand_locations[event.player_index] = cur_hand
    -- When we drop from hand back to inventory, we get the inventory change b/f the stack is gone, so
    -- do nothing...
    if old_hand and not cur_hand and event.name == defines.events.on_player_main_inventory_changed then
        local cs = player.cursor_stack
        if cs and cs.valid_for_read then
            player_cursor_stacks[event.player_index] = {name=cs.name, count=cs.count}
        else
            player_cursor_stacks[event.player_index] = nil
        end
        player_inventories[event.player_index] = cur_inv
        return
    end

    for name, count in pairs(cur_inv) do
        if old_inv[name] then
            if old_inv[name] > count then
                lost_inv_items[name] = old_inv[name] - count
            elseif old_inv[name] < count then
                new_inv_items[name] = count - old_inv[name]
            end
            old_inv[name] = nil
        else
            new_inv_items[name] = count
        end
    end
    for name, count in pairs(old_inv) do
        lost_inv_items[name] = count
    end

    local old_stack = player_cursor_stacks[event.player_index]
    local cs = player.cursor_stack
    local new_curs_items = {}
    local lost_curs_items = {}
    if event.player_index == debug_player then
        log("old_stack " .. serpent.line(old_stack))        
    end

    if cs.valid_for_read then
        if old_stack == nil then
            new_curs_items[cs.name] = cs.count
        elseif old_stack.name ~= cs.name then
            lost_curs_items[old_stack.name] = old_stack.count
            new_curs_items[cs.name] = cs.count
        else
            if old_stack.count > cs.count then
                lost_curs_items[cs.name] = old_stack.count - cs.count
            elseif old_stack.count < cs.count then
                lost_curs_items[cs.name] = cs.count - old_stack.count
            end
        end
        player_cursor_stacks[event.player_index] = {name=cs.name, count=cs.count}
    else
        if old_stack ~= nil then
            lost_curs_items[old_stack.name] = old_stack.count
            player_cursor_stacks[event.player_index] = nil
        end
    end

    -- merge inv/curs new/lost
    for name, count in pairs(new_curs_items) do
        if lost_inv_items[name] ~= nil then
            if lost_inv_items[name] == count then
                lost_inv_items[name] = nil
            elseif lost_inv_items[name] > count then
                lost_inv_items[name] = lost_inv_items[name] - count
            else
                new_inv_items[name] = count - lost_inv_items[name]
                lost_inv_items[name] = nil
            end
        elseif new_inv_items[name] == nil then
            new_inv_items[name] = count
        else
            new_inv_items[name] = new_inv_items[name] + count
        end
    end
    for name, count in pairs(lost_curs_items) do
        if new_inv_items[name] ~= nil then
            if new_inv_items[name] == count then
                new_inv_items[name] = nil
            elseif new_inv_items[name] > count then
                new_inv_items[name] = new_inv_items[name] - count
            else
                lost_inv_items[name] = count - new_inv_items[name]
                new_inv_items[name] = nil
            end
        elseif lost_inv_items[name] == nil then
            lost_inv_items[name] = count
        else
            lost_inv_items[name] = lost_inv_items[name] + count
        end
    end

    for name, count in pairs(lost_inv_items) do
        if event.player_index == debug_player then
            log(event.tick .. " lost " .. count .. " " .. name)
        end
    end
    for name, count in pairs(new_inv_items) do
        if event.player_index == debug_player then
            log(event.tick .. " gained " .. count .. " " .. name)
        end
    end

    if player.selected and player.selected.type ~= "resource" then
        if event.player_index == debug_player then
            log("player selected")
        end
        for name, count in pairs(lost_inv_items) do
            if player.selected.name == "character" then
                slog({event_type="player_gave",
                    tick=event.tick,
                    player_index=event.player_index,
                    to_player_index=player.selected.player.index,
                    position=player.selected.position,
                    entity_name=player.selected.name,
                    item_name=name,
                    count=count,
                })
            else
                emit_drop(event, player.selected, name, count)
            end
        end
        for name, count in pairs(new_inv_items) do
            emit_take(event, player.selected, name, count)
        end
    elseif player.opened_gui_type == defines.gui_type.entity then
        if event.player_index == debug_player then
            log("open gui")
        end
        local opened = player.opened
        if opened.type == "container" or opened.type == "assembling-machine" or
                opened.type == "rocket-silo" or opened.type == "beacon" or opened.type == "lab" or
                opened.type == "boiler" then
            for name, count in pairs(lost_inv_items) do
                emit_drop(event, opened, name, count)
            end
            for name, count in pairs(new_inv_items) do
                emit_take(event, opened, name, count)
            end
        end
    else
        if event.player_index == debug_player then
            log("oops?")
            log("gui .. " .. player.opened_gui_type)
        end
        -- dropping on ground?
    end

    if event.player_index == debug_player then
        log("new_inv " .. serpent.line(cur_inv))
        log("new_stack " .. serpent.line(player_cursor_stacks[event.player_index]))        
    end

    player_inventories[event.player_index] = cur_inv
end
)

script.on_event(defines.events.on_player_flushed_fluid,
function(event)
    slog({event_type="on_player_flushed_fluid",
    tick=event.tick,
    player_index=event.player_index,
    fluid=event.fluid,
    only_this_entity=event.only_this_entity,
    position=event.entity.position,
    name=event.entity.name,
    type=event.entity.type})
end
)

script.on_event(defines.events.on_cancelled_deconstruction,
function(event)
    slog({event_type="on_cancelled_deconstruction",
    tick=event.tick,
    player_index=event.player_index,
    position=event.entity.position,
    name=event.entity.name,
    type=event.entity.type})
end
)

script.on_event(defines.events.on_marked_for_deconstruction,
function(event)
    slog({event_type="on_marked_for_deconstruction",
    tick=event.tick,
    player_index=event.player_index,
    position=event.entity.position,
    name=event.entity.name,
    type=event.entity.type})
end
)

script.on_event(defines.events.on_picked_up_item ,
function(event)
    local inv = player_inventories[event.player_index]
    if not inv[event.item_stack.name] then
        inv[event.item_stack.name] = event.item_stack.count
    else
        inv[event.item_stack.name] = inv[event.item_stack.name] + event.item_stack.count
    end
    slog({event_type="on_picked_up_item",
    tick=event.tick,
    player_index=event.player_index,
    position=game.players[event.player_index].position,
    item_stack=event.item_stack})
end
)