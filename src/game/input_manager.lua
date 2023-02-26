controls.register_on_press(function(player, key)
  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name, "block_league") or arena_lib.is_player_spectating(p_name) then return end

  if key == "aux1" and not arena_lib.get_arena_by_player(p_name).in_celebration then
    panel_lib.get_panel(p_name, "bl_info_panel"):show()
  end
end)



controls.register_on_release(function(player, key)
  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name, "block_league") or arena_lib.is_player_spectating(p_name) then return end

  -- AUX1
  if key == "aux1"  and not arena_lib.get_arena_by_player(p_name).in_celebration then
    panel_lib.get_panel(p_name, "bl_info_panel"):hide()
  end
end)
