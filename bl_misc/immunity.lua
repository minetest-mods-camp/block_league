function block_league.immunity(player)

  local p_name = player:get_player_name()
  local p_meta = player:get_meta()
  local immunity_time = arena_lib.get_arena_by_player(p_name).immunity_time

  p_meta:set_int("bl_immunity", 1)

  minetest.after(immunity_time, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    if p_meta:get_int("bl_immunity") == 1 then
      p_meta:set_int("bl_immunity", 0)
    end
  end)

end
