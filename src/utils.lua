function block_league.sound_play(sound, p_name)
  minetest.sound_play(sound, {to_player = p_name})

  if arena_lib.is_player_spectated(p_name) then
    for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
      minetest.sound_play(sound, {to_player = sp_name})
    end
  end
end
