local S = minetest.get_translator("block_league")

local function wait_for_respawn() end
local function remove_weapons() end



minetest.register_on_joinplayer(function(player)
  player:get_meta():set_string("bl_profile_elem_active", "")

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

  -- non è possibile modificare l'inventario da offline. Se sono crashati o hanno
  -- chiuso il gioco in partita, questo è l'unico modo per togliere loro l'arma
  remove_weapons(player:get_inventory())

  -- se il server è crashato, disabilito l'abilità rimasta
  p_name:get_skill(block_league.get_player_skill(p_name)):disable()
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
