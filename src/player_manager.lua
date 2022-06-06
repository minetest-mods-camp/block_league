local S = minetest.get_translator("block_league")

local function wait_for_respawn() end
local function remove_weapons() end



minetest.register_on_joinplayer(function(player)

  local p_name = player:get_player_name()

  block_league.init_equip(p_name)

  -- se non è nello spazio d'archiviazione della mod, lo aggiungo
  if not block_league.is_player_in_storage(p_name) then
    block_league.create_player_data(p_name)
  else
    block_league.load_player_data(p_name)
  end

  -- genero l'HUD per i prestigi
  block_league.HUD_achievements_create(p_name)

  -- non è possibile modificare l'inventario da offline. Se sono crashati o hanno chiuso il gioco in partita,
  -- questo è l'unico modo per togliere loro l'arma
  remove_weapons(player:get_inventory())
end)



minetest.register_on_respawnplayer(function(player)

  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name, "block_league") or arena_lib.is_player_spectating(p_name) then
    return
  end

  local arena = arena_lib.get_arena_by_player(p_name)

  -- se resuscita mentre non può ancora rientrare in partita, lo porto nella sala d'attesa
  if player:get_meta():get_int("bl_death_delay") == 1 then
    if arena.players[p_name].teamID == 1 then
      player:set_pos(arena.waiting_room_orange)
    else
      player:set_pos(arena.waiting_room_blue)
    end
  else
    block_league.HUD_spectate_update(arena, p_name, "alive")
  end

  arena.players[p_name].energy = 100
  block_league.HUD_energy_update(arena, p_name)

  block_league.refill_weapons(arena, p_name)

  player:set_physics_override({ speed = block_league.SPEED })
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function remove_weapons(inv)

  inv:remove_item("main", ItemStack("block_league:smg"))
  inv:remove_item("main", ItemStack("block_league:sword"))
  inv:remove_item("main", ItemStack("block_league:pixelgun"))
  inv:remove_item("main", ItemStack("block_league:rocket_launcher"))
  inv:remove_item("main", ItemStack("block_league:bouncer"))
  inv:remove_item("main", ItemStack("block_league:testkit_quit"))

end
