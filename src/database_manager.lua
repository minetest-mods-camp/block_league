block_league.players = {}      -- KEY: p_name, INDEX: {lv (int), xp (int), kills (int), time_playing (int)}

local storage = minetest.get_mod_storage()



function block_league.init_storage()

  -- carico tutti i giocatori
  for pl_name, pl_stats in pairs(storage:to_table().fields) do
    block_league.players[pl_name] = minetest.deserialize(pl_stats)
  end

end



function block_league.add_player_to_storage(p_name)
  block_league.players[p_name] = {LV = 0, XP = 0, KILLS = 0, TIME_PLAYING = 0}
  storage:set_string(p_name, minetest.serialize(block_league.players[p_name]))
end



function block_league.update_storage(p_name)
  storage:set_string( p_name, minetest.serialize(block_league.players[p_name]))
end



function block_league.is_player_in_storage(p_name)
  return storage:get_string(p_name) ~= ""
end
