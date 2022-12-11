script.on_event(defines.events.on_ai_command_completed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_ai_command_completed")
            end
        )
        script.on_event(defines.events.on_area_cloned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_area_cloned")
            end
        )
        script.on_event(defines.events.on_biter_base_built,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_biter_base_built")
            end
        )
        script.on_event(defines.events.on_brush_cloned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_brush_cloned")
            end
        )
        script.on_event(defines.events.on_build_base_arrived,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_build_base_arrived")
            end
        )
        script.on_event(defines.events.on_built_entity,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_built_entity")
            end
        )
        script.on_event(defines.events.on_cancelled_deconstruction,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_cancelled_deconstruction")
            end
        )
        script.on_event(defines.events.on_cancelled_upgrade,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_cancelled_upgrade")
            end
        )
        script.on_event(defines.events.on_character_corpse_expired,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_character_corpse_expired")
            end
        )
        script.on_event(defines.events.on_chart_tag_added,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_chart_tag_added")
            end
        )
        script.on_event(defines.events.on_chart_tag_modified,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_chart_tag_modified")
            end
        )
        script.on_event(defines.events.on_chart_tag_removed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_chart_tag_removed")
            end
        )

        script.on_event(defines.events.on_chunk_deleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_chunk_deleted")
            end
        )

        script.on_event(defines.events.on_combat_robot_expired,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_combat_robot_expired")
            end
        )
        script.on_event(defines.events.on_console_chat,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_console_chat")
            end
        )
        script.on_event(defines.events.on_console_command,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_console_command")
            end
        )
        script.on_event(defines.events.on_cutscene_cancelled,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_cutscene_cancelled")
            end
        )
        script.on_event(defines.events.on_cutscene_waypoint_reached,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_cutscene_waypoint_reached")
            end
        )
        script.on_event(defines.events.on_difficulty_settings_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_difficulty_settings_changed")
            end
        )
        script.on_event(defines.events.on_entity_cloned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_entity_cloned")
            end
        )
        --script.on_event(defines.events.on_entity_damaged,
          --  function(event)
          --      game.print(event.name .. " " .. event.tick .." on_entity_damaged")
          --  end
        --)
        script.on_event(defines.events.on_entity_destroyed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_entity_destroyed")
            end
        )
        script.on_event(defines.events.on_entity_died,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_entity_died")
            end
        )
  
        script.on_event(defines.events.on_entity_renamed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_entity_renamed")
            end
        )
        script.on_event(defines.events.on_entity_settings_pasted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_entity_settings_pasted")
            end
        )
        script.on_event(defines.events.on_entity_spawned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_entity_spawned")
            end
        )

        script.on_event(defines.events.on_force_cease_fire_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_force_cease_fire_changed")
            end
        )
        script.on_event(defines.events.on_force_created,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_force_created")
            end
        )
        script.on_event(defines.events.on_force_friends_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_force_friends_changed")
            end
        )
        script.on_event(defines.events.on_force_reset,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_force_reset")
            end
        )
        script.on_event(defines.events.on_forces_merged,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_forces_merged")
            end
        )
        script.on_event(defines.events.on_forces_merging,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_forces_merging")
            end
        )
        script.on_event(defines.events.on_game_created_from_scenario,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_game_created_from_scenario")
            end
        )
        script.on_event(defines.events.on_gui_checked_state_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_checked_state_changed")
            end
        )
        script.on_event(defines.events.on_gui_click,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_click")
            end
        )
        script.on_event(defines.events.on_gui_closed,
            function(event)
                if event.gui_type == defines.gui_type.entity then
                    if event.entity.type == "assembling-machine" then
                        local recipe = event.entity.get_recipe()
                        if recipe then
                            game.print("recipe: " .. recipe.name)
                        else
                            game.print("no recipe")
                        end
                    else
                        game.print(event.entity.type)
                    end
                end
                game.print(event.name .. " " .. event.tick .." on_gui_closed")
            end
        )
        script.on_event(defines.events.on_gui_confirmed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_confirmed")
            end
        )
        script.on_event(defines.events.on_gui_elem_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_elem_changed")
            end
        )
        script.on_event(defines.events.on_gui_location_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_location_changed")
            end
        )
        script.on_event(defines.events.on_gui_opened,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_opened")
            end
        )
        script.on_event(defines.events.on_gui_selected_tab_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_selected_tab_changed")
            end
        )
        script.on_event(defines.events.on_gui_selection_state_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_selection_state_changed")
            end
        )
        script.on_event(defines.events.on_gui_switch_state_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_switch_state_changed")
            end
        )
        script.on_event(defines.events.on_gui_text_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_text_changed")
            end
        )
        script.on_event(defines.events.on_gui_value_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_gui_value_changed")
            end
        )
        script.on_event(defines.events.on_land_mine_armed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_land_mine_armed")
            end
        )
        script.on_event(defines.events.on_lua_shortcut,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_lua_shortcut")
            end
        )
        script.on_event(defines.events.on_marked_for_deconstruction,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_marked_for_deconstruction")
            end
        )
        script.on_event(defines.events.on_marked_for_upgrade,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_marked_for_upgrade")
            end
        )
        script.on_event(defines.events.on_market_item_purchased,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_market_item_purchased")
            end
        )
        script.on_event(defines.events.on_mod_item_opened,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_mod_item_opened")
            end
        )
        script.on_event(defines.events.on_permission_group_added,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_permission_group_added")
            end
        )
        script.on_event(defines.events.on_permission_group_deleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_permission_group_deleted")
            end
        )
        script.on_event(defines.events.on_permission_group_edited,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_permission_group_edited")
            end
        )
        script.on_event(defines.events.on_permission_string_imported,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_permission_string_imported")
            end
        )
        script.on_event(defines.events.on_picked_up_item,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_picked_up_item")
            end
        )
        script.on_event(defines.events.on_player_alt_selected_area,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_alt_selected_area")
            end
        )
        script.on_event(defines.events.on_player_ammo_inventory_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_ammo_inventory_changed")
            end
        )
        script.on_event(defines.events.on_player_armor_inventory_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_armor_inventory_changed")
            end
        )
        script.on_event(defines.events.on_player_banned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_banned")
            end
        )
        script.on_event(defines.events.on_player_built_tile,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_built_tile")
            end
        )
        script.on_event(defines.events.on_player_cancelled_crafting,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_cancelled_crafting")
            end
        )
        script.on_event(defines.events.on_player_changed_force,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_changed_force")
            end
        )
        script.on_event(defines.events.on_player_changed_position,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_changed_position")
            end
        )
        script.on_event(defines.events.on_player_changed_surface,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_changed_surface")
            end
        )
        script.on_event(defines.events.on_player_cheat_mode_disabled,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_cheat_mode_disabled")
            end
        )
        script.on_event(defines.events.on_player_cheat_mode_enabled,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_cheat_mode_enabled")
            end
        )
        script.on_event(defines.events.on_player_clicked_gps_tag,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_clicked_gps_tag")
            end
        )
        script.on_event(defines.events.on_player_configured_blueprint,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_configured_blueprint")
            end
        )
        script.on_event(defines.events.on_player_configured_spider_remote,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_configured_spider_remote")
            end
        )
        script.on_event(defines.events.on_player_crafted_item,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_crafted_item")
            end
        )
        script.on_event(defines.events.on_player_created,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_created")
            end
        )
        script.on_event(defines.events.on_player_cursor_stack_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_cursor_stack_changed")
            end
        )
        script.on_event(defines.events.on_player_deconstructed_area,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_deconstructed_area")
            end
        )
        script.on_event(defines.events.on_player_demoted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_demoted")
            end
        )
        script.on_event(defines.events.on_player_died,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_died")
            end
        )
        script.on_event(defines.events.on_player_display_resolution_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_display_resolution_changed")
            end
        )
        script.on_event(defines.events.on_player_display_scale_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_display_scale_changed")
            end
        )
        script.on_event(defines.events.on_player_driving_changed_state,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_driving_changed_state")
            end
        )
        script.on_event(defines.events.on_player_dropped_item,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_dropped_item")
            end
        )
        script.on_event(defines.events.on_player_fast_transferred,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_fast_transferred")
            end
        )
        script.on_event(defines.events.on_player_flushed_fluid,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_flushed_fluid")
            end
        )
        script.on_event(defines.events.on_player_gun_inventory_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_gun_inventory_changed")
            end
        )
        script.on_event(defines.events.on_player_joined_game,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_joined_game")
            end
        )
        script.on_event(defines.events.on_player_kicked,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_kicked")
            end
        )
        script.on_event(defines.events.on_player_left_game,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_left_game")
            end
        )
        script.on_event(defines.events.on_player_main_inventory_changed,
            function(event)
                if (game.get_player(event.player_index).hand_location == nil) then
                    game.print("empty hand")
                else
                    game.print("full hand")
                end
                game.print(event.name .. " " .. event.tick .." on_player_main_inventory_changed")
            end
        )
        script.on_event(defines.events.on_player_mined_entity,
            function(event)
                game.print(event.entity.position)
                game.print(event.entity.name .. ": ".. event.entity.object_name)
                game.print(event.name .. " " .. event.tick .." on_player_mined_entity")
            end
        )
        script.on_event(defines.events.on_player_mined_item,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_mined_item")
            end
        )
        script.on_event(defines.events.on_player_mined_tile,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_mined_tile")
            end
        )
        script.on_event(defines.events.on_player_muted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_muted")
            end
        )
        script.on_event(defines.events.on_player_pipette,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_pipette")
            end
        )
        script.on_event(defines.events.on_player_placed_equipment,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_placed_equipment")
            end
        )
        script.on_event(defines.events.on_player_promoted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_promoted")
            end
        )
        script.on_event(defines.events.on_player_removed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_removed")
            end
        )
        script.on_event(defines.events.on_player_removed_equipment,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_removed_equipment")
            end
        )
        script.on_event(defines.events.on_player_repaired_entity,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_repaired_entity")
            end
        )
        script.on_event(defines.events.on_player_respawned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_respawned")
            end
        )

        script.on_event(defines.events.on_player_rotated_entity,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_rotated_entity")
            end
        )
        script.on_event(defines.events.on_player_selected_area,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_selected_area")
            end
        )
        script.on_event(defines.events.on_player_set_quick_bar_slot,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_set_quick_bar_slot")
            end
        )
        script.on_event(defines.events.on_player_setup_blueprint,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_setup_blueprint")
            end
        )
        script.on_event(defines.events.on_player_toggled_alt_mode,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_toggled_alt_mode")
            end
        )
        script.on_event(defines.events.on_player_toggled_map_editor,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_toggled_map_editor")
            end
        )
        script.on_event(defines.events.on_player_trash_inventory_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_trash_inventory_changed")
            end
        )
        script.on_event(defines.events.on_player_unbanned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_unbanned")
            end
        )
        script.on_event(defines.events.on_player_unmuted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_unmuted")
            end
        )
        script.on_event(defines.events.on_player_used_capsule,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_used_capsule")
            end
        )
        script.on_event(defines.events.on_player_used_spider_remote,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_player_used_spider_remote")
            end
        )
        script.on_event(defines.events.on_post_entity_died,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_post_entity_died")
            end
        )

        script.on_event(defines.events.on_pre_chunk_deleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_chunk_deleted")
            end
        )
        script.on_event(defines.events.on_pre_entity_settings_pasted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_entity_settings_pasted")
            end
        )
        script.on_event(defines.events.on_pre_ghost_deconstructed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_ghost_deconstructed")
            end
        )
        script.on_event(defines.events.on_pre_permission_group_deleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_permission_group_deleted")
            end
        )
        script.on_event(defines.events.on_pre_permission_string_imported,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_permission_string_imported")
            end
        )
        script.on_event(defines.events.on_pre_player_crafted_item,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_player_crafted_item")
            end
        )
        script.on_event(defines.events.on_pre_player_died,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_player_died")
            end
        )
        script.on_event(defines.events.on_pre_player_left_game,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_player_left_game")
            end
        )
        script.on_event(defines.events.on_pre_player_mined_item,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_player_mined_item")
            end
        )
        script.on_event(defines.events.on_pre_player_removed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_player_removed")
            end
        )
        script.on_event(defines.events.on_pre_player_toggled_map_editor,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_player_toggled_map_editor")
            end
        )
        script.on_event(defines.events.on_pre_robot_exploded_cliff,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_robot_exploded_cliff")
            end
        )
        script.on_event(defines.events.on_pre_script_inventory_resized,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_script_inventory_resized")
            end
        )
        script.on_event(defines.events.on_pre_surface_cleared,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_surface_cleared")
            end
        )
        script.on_event(defines.events.on_pre_surface_deleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_pre_surface_deleted")
            end
        )

        script.on_event(defines.events.on_research_finished,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_research_finished")
            end
        )

        script.on_event(defines.events.on_research_started,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_research_started")
            end
        )
        script.on_event(defines.events.on_resource_depleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_resource_depleted")
            end
        )
        script.on_event(defines.events.on_robot_built_entity,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_built_entity")
            end
        )
        script.on_event(defines.events.on_robot_built_tile,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_built_tile")
            end
        )
        script.on_event(defines.events.on_robot_exploded_cliff,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_exploded_cliff")
            end
        )
        script.on_event(defines.events.on_robot_mined,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_mined")
            end
        )
        script.on_event(defines.events.on_robot_mined_entity,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_mined_entity")
            end
        )
        script.on_event(defines.events.on_robot_mined_tile,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_mined_tile")
            end
        )
        script.on_event(defines.events.on_robot_pre_mined,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_robot_pre_mined")
            end
        )
        script.on_event(defines.events.on_rocket_launch_ordered,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_rocket_launch_ordered")
            end
        )
        script.on_event(defines.events.on_rocket_launched,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_rocket_launched")
            end
        )
        script.on_event(defines.events.on_runtime_mod_setting_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_runtime_mod_setting_changed")
            end
        )
        script.on_event(defines.events.on_script_inventory_resized,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_script_inventory_resized")
            end
        )
        script.on_event(defines.events.on_script_path_request_finished,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_script_path_request_finished")
            end
        )
        script.on_event(defines.events.on_script_trigger_effect,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_script_trigger_effect")
            end
        )
        script.on_event(defines.events.on_sector_scanned,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_sector_scanned")
            end
        )
        script.on_event(defines.events.on_selected_entity_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_selected_entity_changed")
                if game.players[event.player_index].selected and game.players[event.player_index].selected.type == "underground-belt" then
                    game.print("belt_to_ground_type: " .. game.players[event.player_index].selected.belt_to_ground_type)
                end
            end
        )

        script.on_event(defines.events.on_string_translated,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_string_translated")
            end
        )
        script.on_event(defines.events.on_surface_cleared,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_surface_cleared")
            end
        )
        script.on_event(defines.events.on_surface_created,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_surface_created")
            end
        )
        script.on_event(defines.events.on_surface_deleted,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_surface_deleted")
            end
        )
        script.on_event(defines.events.on_surface_imported,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_surface_imported")
            end
        )
        script.on_event(defines.events.on_surface_renamed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_surface_renamed")
            end
        )
        script.on_event(defines.events.on_technology_effects_reset,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_technology_effects_reset")
            end
        )

        script.on_event(defines.events.on_train_changed_state,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_train_changed_state")
            end
        )
        script.on_event(defines.events.on_train_created,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_train_created")
            end
        )
        script.on_event(defines.events.on_train_schedule_changed,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_train_schedule_changed")
            end
        )
        script.on_event(defines.events.on_trigger_created_entity,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_trigger_created_entity")
            end
        )
        script.on_event(defines.events.on_trigger_fired_artillery,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_trigger_fired_artillery")
            end
        )
        script.on_event(defines.events.on_unit_added_to_group,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_unit_added_to_group")
            end
        )
        script.on_event(defines.events.on_unit_group_created,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_unit_group_created")
            end
        )
        script.on_event(defines.events.on_unit_group_finished_gathering,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_unit_group_finished_gathering")
            end
        )
        script.on_event(defines.events.on_unit_removed_from_group,
            function(event)
                game.print(event.name .. " " .. event.tick .." on_unit_removed_from_group")
            end
        )


local player_cursor_stacks = {}
local player_inventories = {
    [1] = {["burner-mining-drill"] = 1, ["stone-furnace"] = 1, wood = 1}
}
local player_hand_locations = {}

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

local emit = function(table)
    game.print(serpent.line(table))
end

local emit_drop = function(event, entity, name, count)
    emit({event_type="player_dropped",
        tick=event.tick,
        player_index=event.player_index,
        position=entity.position,
        entity_name=entity.name,
        item_name=name,
        count=count,
    })
end

local emit_take = function(event, entity, name, count)
    emit({event_type="player_took",
        tick=event.tick,
        player_index=event.player_index,
        position=entity.position,
        entity_name=entity.name,
        item_name=name,
        count=count,
    })
end
        
script.on_event({defines.events.on_player_main_inventory_changed, defines.events.on_player_cursor_stack_changed, defines.events.on_player_fast_transferred},
function(event)
    if event.name == defines.events.on_player_main_inventory_changed then
        emit('main_inv')
    else
        emit('curs stack')
    end
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

    emit("old stack")
    emit(old_stack)


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

    emit("lost")
    emit(lost_curs_items)


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