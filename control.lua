local handler = require("event_handler")
handler.add_lib(require("freeplay"))
handler.add_lib(require("silo-script"))

local player_cursor_stacks = {}
local player_inventories = {}
local player_selected_entities = {}

local function slog(table)
    log("rlog: " .. serpent.line(table))
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
            e.recipe = ce.get_recipe()
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

script.on_event(defines.events.on_player_cursor_stack_changed,
    function(event)
        local player = game.get_player(event.player_index)
        local cs = player.cursor_stack
        if player.cursor_stack.valid_for_read and player.cursor_stack.type == "item" then
            local old_stack = player_cursor_stacks[event.player_index]
            if old_stack == nil or old_stack.name ~= cs.name then
                player_cursor_stacks[event.player_index] = {name=cs.name, count=cs.count}
            else
                if cs.count ~= old_stack.count then
                    if cs.count < old_stack.count then
                        if player.selected ~= nil and player.selected.type ~= "resource" then
                            slog({event_type="player_dropped",
                            tick=event.tick,
                            player_index=event.player_index,
                            position=player.selected.position,
                            entity_name=player.selected.name,
                            item_name=cs.name,
                            count=old_stack.count-cs.count,
                            })
                        end
                    end
                end
                player_cursor_stacks[event.player_index] = {name=cs.name, count=cs.count}
            end
        else
            player_cursor_stacks[event.player_index] = nil
        end 
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

script.on_event(defines.events.on_player_main_inventory_changed,
function(event)
    -- TBD
end
)
