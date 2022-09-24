local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

local player_cursor_stacks = {}
local player_inventories = {
    [1] = {["burner-mining-drill"] = 1, ["stone-furnace"] = 1, wood = 1}
}
local player_selected_entities = {}
local player_hand_locations = {}
local last_moved = {[1] = 0}
local last_position = {[1] = {0, 0}}

local function slog(table)
    log("rlog: " .. serpent.line(table))
end

for i = 2,8 do
    player_inventories[i] = {["burner-mining-drill"] = 1, ["stone-furnace"] = 1, wood = 1, ["iron-plate"] = 8}
    last_moved[i] = 0
    last_position[i] = {0, 0}
end

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
        end
        if type == "underground-belt" then
            e.belt_to_ground_type = ce.belt_to_ground_type
        elseif type == "assembling-machine" then
            if ce.get_recipe() then
                e.recipe = ce.get_recipe().name
            end
        elseif type == "container" then
            local inv = ce.get_inventory(defines.inventory.chest)
            ok, err = pcall(function() e.bar = inv.get_bar() end)
            if not ok then
                game.print(err.. " " .. serpent.line(e))
            end
            e.bar = inv.get_bar()
        elseif type == "item-entity" then
            e.stack = event.stack
        end
        slog(e)
        
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
        slog({event_type="on_player_rotated_entity",
        tick=event.tick,
        player_index=event.player_index,
        position=event.entity.position,
        direction=event.entity.direction,
        name=event.entity.name,
        type=event.entity.type})
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
        end
    end
end
)

local flatten_inventory = function(inventory)
    flat_inv = {}
    for i=1,#inventory do
        local ci = inventory[i]
        if ci.valid_for_read then
            if flat_inv[ci.name] == nil then
                flat_inv[ci.name] = ci.count
            else
                flat_inv[ci.name] = flat_inv[ci.name] + ci.count
            end
        end
    end
    return flat_inv
end

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
    -- Rate limit to once a second
    for i = 1,8 do
        local player = game.get_player(i)
        if player and event.tick > last_moved[i] + 60 then
            if last_position[i][1] ~= player.position.x or last_position[i][2] ~= player.position.y then 
                slog({event_type="on_player_changed_position",
                    tick=event.tick,
                    player_index=i,
                    position=player.position
                })
                last_moved[i] = event.tick
                last_position[i] = player.position
            end
        end
        if player.cursor_stack.valid_for_read and player.cursor_stack.type == 'blueprint' on_technology_effects_reset then
            -- try to determine if they pasted the blueprint??
        end
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
    end
end)

script.on_event({defines.events.on_player_main_inventory_changed, defines.events.on_player_cursor_stack_changed, defines.events.on_player_fast_transferred},
function(event)
    -- we could actually use the info on fast transfer events...
    local old_inv = player_inventories[event.player_index]
    local player = game.get_player(event.player_index)
    local cur_inv = player.get_main_inventory()
    cur_inv = flatten_inventory(cur_inv)
    local new_inv_items = {}
    local lost_inv_items = {}

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

    if player.selected and player.selected.type ~= "resource" then
        for name, count in pairs(lost_inv_items) do
            emit_drop(event, player.selected, name, count)
        end
        for name, count in pairs(new_inv_items) do
            emit_take(event, player.selected, name, count)
        end
    elseif player.opened_gui_type == defines.gui_type.entity then
        local opened = player.opened
        if opened.type == "container" or opened.type == "assembling-machine" then
            for name, count in pairs(lost_inv_items) do
                emit_drop(event, opened, name, count)
            end
            for name, count in pairs(new_inv_items) do
                emit_take(event, opened, name, count)
            end
        end
    else
        -- dropping on ground?
    end

    player_inventories[event.player_index] = cur_inv
end
)