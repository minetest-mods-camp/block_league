controls.register_on_press(function(player, key)

  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name, "block_league") then return end

  if key == "aux1" and not arena_lib.get_arena_by_player(p_name).in_celebration then
    panel_lib.get_panel(p_name, "bl_info_panel"):show()
  end
end)



controls.register_on_hold(function(player, key)

  local p_name = player:get_player_name()

  if key~="LMB" or not arena_lib.is_player_in_arena(p_name, "block_league") then return end

  local weapon_name = player:get_wielded_item():get_name()
  local weap_def = minetest.registered_nodes[weapon_name]

  if not weap_def or not weap_def.continuos_fire then return end

  block_league.shoot(weap_def, player)

end)



controls.register_on_release(function(player, key)

  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name, "block_league") then return end

  -- AUX1
  if key == "aux1"  and not arena_lib.get_arena_by_player(p_name).in_celebration then
    panel_lib.get_panel(p_name, "bl_info_panel"):hide()


  -- LMB
  elseif key == "LMB" then

    local weapon_name = player:get_wielded_item():get_name()
    local weap_def = minetest.registered_nodes[weapon_name]
    local arena = arena_lib.get_arena_by_player(p_name)

    if not weap_def or not weap_def.slow_down_when_firing then return end

      minetest.after(0.5, function()
        if not arena_lib.is_player_in_arena(p_name, "block_league") or arena.players[p_name].energy == 0 then return end
        player:set_physics_override({
          speed = block_league.SPEED,
          jump = 1.5
        })
      end)
   end
end)
