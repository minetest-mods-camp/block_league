local recursive_time = 0.1



function block_league.stamina_refill_loop(arena)
  if not arena.in_game then return end

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)
    local health = player:get_hp()
    local stamina = arena.players[pl_name].stamina
    local max_stamina = arena.players[pl_name].stamina_max

    -- se è vivo, senza palla e con energia non al massimo
    if health > 0 and player:get_meta():get_int("bl_has_ball") == 0 and stamina < max_stamina then
      arena.players[pl_name].stamina = stamina + 1
      block_league.HUD_stamina_update(arena, pl_name)
    end
  end

  minetest.after(recursive_time, function() block_league.stamina_refill_loop(arena) end)
end



function block_league.stamina_drain(arena, w_name)
  -- per vedere se è connessə devo per forza fare minetest.ecc, quindi è inutile passare l'intero giocatore come parametro (dato che mi serve il nome)
  local wielder = minetest.get_player_by_name(w_name)

  if not arena.in_game or not wielder or wielder:get_meta():get_int("bl_has_ball") == 0 then return end

  if arena.players[w_name].stamina > 0 then
    arena.players[w_name].stamina = arena.players[w_name].stamina -2
    block_league.HUD_stamina_update(arena, w_name)
  else
    arena.players[w_name].stamina = 0 -- in case went to -1
    wielder:set_physics_override({speed = block_league.SPEED_LOW})
    return
  end

  minetest.after(recursive_time, function() block_league.stamina_drain(arena, w_name) end)
end
