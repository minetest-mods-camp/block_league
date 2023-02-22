function block_league.fall_check_loop(arena)

  if not arena.in_game then return end

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)

    if player:get_hp() > 0 and player:get_pos().y < arena.min_y then
      player:set_hp(0)
      player:get_meta():set_int("bl_has_ball", 0)

      local last_hitter = ""
      local last_hitter_timestamp = 99999

      for pla_name, dmg_data in pairs(stats.dmg_received) do
        if arena.current_time > dmg_data.timestamp - 5 and last_hitter_timestamp > dmg_data.timestamp then
          last_hitter = pla_name
          last_hitter_timestamp = dmg_data.timestamp
        end
      end

      if last_hitter ~= "" then
        block_league.kill(arena, minetest.registered_nodes[stats.dmg_received[last_hitter].weapon], minetest.get_player_by_name(last_hitter), player)
      else
        block_league.HUD_log_update(arena, "bl_log_suicide.png", pl_name, "")
      end
    end
  end

  minetest.after(0.1, function() block_league.fall_check_loop(arena) end)
end
