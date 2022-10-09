local p_data = {}      -- KEY: p_name, INDEX: {equip = {weapons = {...}, skill = s_name}}

local storage = minetest.get_mod_storage()



function block_league.create_player_data(p_name)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun"}
  local default_skill = "block_league:hp"

  p_name:unlock_skill("block_league:hp")
  p_name:unlock_skill("block_league:sp")
  p_name:get_skill("block_league:hp"):disable()
  p_name:get_skill("block_league:sp"):disable()

  --TODO: indagare "non puoi usare questa abilità adesso" inviato due volte al primo accesso

  p_data[p_name] = {}
  p_data[p_name].equip = {}

  block_league.set_player_weapons(p_name, default_weapons)
  block_league.set_player_skill(p_name, default_skill)
  p_data[p_name] = {equip = { weapons = default_weapons, skill = default_skill}} -- this line will become useless once custom weapons are implemented
  storage:set_string(p_name, minetest.serialize(p_data[p_name]))
end



function block_league.load_player_data(p_name)
  p_data[p_name] = minetest.deserialize(storage:get_string(p_name))
  block_league.set_player_weapons(p_name, p_data[p_name].equip.weapons)
  block_league.set_player_skill(p_name, p_data[p_name].equip.skill)
end


-- appunti per il futuro:
-- 1. meglio tenere `type` e `param`, dato che si allacceranno armi, abilità,
-- esperienza e valuta della mod;
-- 2. meglio evitare di fare un pastone in una classe enorme, col rischio di
-- creare confusione. Meglio un po' più di ridondanza nelle funzioni (es. x
-- salvare abilità: set_skill -> update_storage, piuttosto che tutto qui dentro)
function block_league.update_storage(p_name, type, param)
  if type == "skill" then
    p_data[p_name].equip.skill = param
  end

  storage:set_string( p_name, minetest.serialize(p_data[p_name]))
end



function block_league.is_player_in_storage(p_name)
  return storage:get_string(p_name) ~= ""
end
