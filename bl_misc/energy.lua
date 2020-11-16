local recursive_time = 0.1



function block_league.energy_refill_loop(arena)

  if not arena.in_game then return end

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)
    local health = player:get_hp()

    -- se è vivo
    if health > 0 then
      if player:get_meta():get_int("bl_has_ball") == 0 and arena.players[pl_name].energy < arena.max_energy then
        arena.players[pl_name].energy = arena.players[pl_name].energy + 1
        block_league.energy_update(arena, pl_name)
      end

      if player:get_pos().y < arena.min_y then
        player:set_hp(0)
        player:get_meta():set_int("bl_has_ball", 0)
      end
    end
  end

  minetest.after(recursive_time, function() block_league.energy_refill_loop(arena) end)
end



function block_league.energy_drain(arena, w_name)

  -- per vedere se è online devo per forza fare minetest.ecc, dacché è inutile passare l'intero giocatore come parametro (dato che mi serve il nome)
  local wielder = minetest.get_player_by_name(w_name)

  if not arena.in_game or not wielder or wielder:get_meta():get_int("bl_has_ball") == 0 then return end

  if arena.players[w_name].energy > 0 then
    arena.players[w_name].energy = arena.players[w_name].energy -2
    block_league.energy_update(arena, w_name)
  else
    wielder:set_physics_override({speed = block_league.SPEED_LOW})
    return
  end

  minetest.after(recursive_time, function() block_league.energy_drain(arena, w_name) end)
end
