local function death_delay() end
local function remove_weapons() end



minetest.register_on_joinplayer(function(player)

  local p_name = player:get_player_name()

  -- se non è nello storage degli achievement, lo aggiungo
  if not achievements_lib.is_player_in_storage(p_name, "block_league") then
    achievements_lib.add_player_to_storage(p_name, "block_league")
  end

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

  local arena = arena_lib.get_arena_by_player(p_name)

  arena.players[p_name].energy = 100
  block_league.energy_update(arena, p_name)
  player:get_meta():set_int("bl_death_delay", 1)
  arena.players[p_name].weapons_magazine = {}

  minetest.after(6, function()
    if not player or not player:get_meta() then return end
    player:get_meta():set_int("bl_death_delay", 0)
    player:get_meta():set_int("bl_reloading", 0)
  end)

end)



minetest.register_on_respawnplayer(function(player)

  if not arena_lib.is_player_in_arena(player:get_player_name(), "block_league") then return end

  local pos = player:get_pos()

  death_delay(player, pos)
  player:set_physics_override({
            speed = block_league.SPEED,
            jump = 1.5
  })

  -- TEMP: da rimuovere quando giocatori avranno tabella armi
  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun"}

  for i, weapon_name in pairs(default_weapons) do
    local magazine = minetest.registered_nodes[weapon_name].magazine

    if magazine then
      arena.players[p_name].weapons_magazine[weapon_name] = magazine
      block_league.weapons_hud_update(arena, p_name, weapon_name, magazine)
    end
  end

  block_league.immunity(player)
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function death_delay(player, pos)
  if player and player:get_meta() then
    local delay = player:get_meta():get_int("bl_death_delay")
    if delay == 1 and arena_lib.is_player_in_arena(player:get_player_name(), "block_league") then
      player:set_pos(pos)
    else
      return
    end
  end
  minetest.after(0.1, function() death_delay(player, pos) end)
end



function remove_weapons(inv)

  inv:remove_item("main", ItemStack("block_league:smg"))
  inv:remove_item("main", ItemStack("block_league:sword"))
  inv:remove_item("main", ItemStack("block_league:pixelgun"))
  inv:remove_item("main", ItemStack("block_league:rocket_launcher"))
  inv:remove_item("main", ItemStack("block_league:bouncer"))

end
