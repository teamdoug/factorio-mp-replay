local player_events = require("player_events")

local my_index = 7

local events_to_run = {}
script.on_init(function()
   global.mp_event_index = 1
end)


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
            local success
            if event.event_type == "on_player_mined_entity" then
                success = mine_entity(event)
            else
                success = true
                game.print("bad event: " .. serpent.line(event))
            end
            if not success then
                if event.tick == tick then
                    game.print("failed to execute event: " .. serpent.line(event))
                end
                table.insert(new_events_to_run, event)
            end
        end
    end
    events_to_run = new_events_to_run

end)