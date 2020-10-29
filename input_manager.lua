controls.register_on_press(function(player, key)

  local p_name = player:get_player_name()

  if key == "aux1" and arena_lib.is_player_in_arena(p_name, "block_league") and not arena_lib.get_arena_by_player(p_name).in_celebration then
    panel_lib.get_panel(p_name, "bl_scoreboard"):show()
  end
end)



controls.register_on_release(function(player, key)

  local p_name = player:get_player_name()

  if key == "aux1" and arena_lib.is_player_in_arena(p_name, "block_league") and not arena_lib.get_arena_by_player(p_name).in_celebration then
    panel_lib.get_panel(p_name, "bl_scoreboard"):hide()
  end
end)
