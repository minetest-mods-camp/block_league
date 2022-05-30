local p_data = {}      -- KEY: p_name, INDEX: {equip = {weapons = {...}}}

local storage = minetest.get_mod_storage()



-- TODO: una funzione legata a un comando per aggiornare tutto il database quando viene in qualche modo modificato,
-- sennò bisogna stare a ricancellarlo ogni volta, e magari anche no
function block_league.create_player_data(p_name)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun"}
  block_league.set_player_weapons(p_name, default_weapons)
  p_data[p_name] = {equip = { weapons = default_weapons}}
  storage:set_string(p_name, minetest.serialize(p_data[p_name]))
end



function block_league.load_player_data(p_name)
  p_data[p_name] = minetest.deserialize(storage:get_string(p_name))
  block_league.set_player_weapons(p_name, p_data[p_name].equip.weapons)
end



function block_league.update_storage(p_name)
  storage:set_string( p_name, minetest.serialize(p_data[p_name]))
end



function block_league.is_player_in_storage(p_name)
  return storage:get_string(p_name) ~= ""
end
