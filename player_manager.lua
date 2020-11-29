local S = minetest.get_translator("block_league")

local function wait_for_respawn() end
local function remove_weapons() end



minetest.register_on_joinplayer(function(player)

  local p_name = player:get_player_name()

  -- se non è nello storage della mod, lo aggiungo
  if not block_league.is_player_in_storage(p_name) then
    block_league.add_player_to_storage(p_name)
  end

  -- genero l'HUD per gli achievement
  block_league.HUD_achievements_create(p_name)

  -- non è possibile modificare l'inventario da offline. Se sono crashati o hanno chiuso il gioco in partita,
  -- questo è l'unico modo per togliere loro l'arma
  remove_weapons(player:get_inventory())

end)



minetest.register_on_dieplayer(function(player)

  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name, "block_league") then return end

  player:get_meta():set_int("bl_death_delay", 1)

  wait_for_respawn(arena_lib.get_arena_by_player(p_name), p_name, 6)
end)



minetest.register_on_respawnplayer(function(player)

  if not arena_lib.is_player_in_arena(player:get_player_name(), "block_league") then return end

  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)

  if player:get_meta():get_int("bl_death_delay") == 1 then
    if arena.players[p_name].teamID == 1 then
      player:set_pos(arena.waiting_room_orange)
    else
      player:set_pos(arena.waiting_room_blue)
    end
  end

  arena.players[p_name].energy = 100
  block_league.energy_update(arena, p_name)

  block_league.refill_weapons(arena, p_name)

  player:set_physics_override({ speed = block_league.SPEED })
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function wait_for_respawn(arena, p_name, time_left)

  if not arena_lib.is_player_in_arena(p_name, "block_league") or arena.weapons_disabled then
    arena_lib.HUD_hide("broadcast", p_name)
  return end

  if time_left > 0 then
    arena_lib.HUD_send_msg("broadcast", p_name, S("Back in the game in @1", time_left))
  else
    local player = minetest.get_player_by_name(p_name)

    player:get_meta():set_int("bl_death_delay", 0)
    player:get_meta():set_int("bl_reloading", 0)
    arena_lib.HUD_hide("broadcast", p_name)

    -- se è nella sala d'attesa
    if player:get_hp() > 0 then
      player:set_pos(arena_lib.get_random_spawner(arena, arena.players[p_name].teamID))
      block_league.immunity(player)
    end

    return
  end

  time_left = time_left -1

  minetest.after(1, function()
    wait_for_respawn(arena, p_name, time_left)
  end)
end



function remove_weapons(inv)

  inv:remove_item("main", ItemStack("block_league:smg"))
  inv:remove_item("main", ItemStack("block_league:sword"))
  inv:remove_item("main", ItemStack("block_league:pixelgun"))
  inv:remove_item("main", ItemStack("block_league:rocket_launcher"))
  inv:remove_item("main", ItemStack("block_league:bouncer"))
  inv:remove_item("main", ItemStack("block_league:testkit_quit"))

end
