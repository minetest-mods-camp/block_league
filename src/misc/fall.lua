function block_league.fall_check_loop(arena)

  if not arena.in_game then return end

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)

    if player:get_hp() > 0 and player:get_pos().y < arena.min_y then
      player:set_hp(0)
      player:get_meta():set_int("bl_has_ball", 0)
      block_league.hud_log_update(arena, "bl_log_suicide.png", pl_name, "")
    end
  end

  minetest.after(0.1, function() block_league.fall_check_loop(arena) end)
end
