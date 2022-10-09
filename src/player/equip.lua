local equip = {}             -- KEY p_name, INDEX { weapons = { 1 = w_name, 2 = w_name, 3 = w_name}, skill = s_name }

--TODO: in futuro verranno aggiunte nuove armi, e questa classe permetterà di gestirle

function block_league.init_equip(p_name)
  equip[p_name] = {}
end



function block_league.get_player_weapons(p_name)
  return equip[p_name].weapons
end



function block_league.get_player_skill(p_name)
  return equip[p_name].skill
end



function block_league.set_player_weapons(p_name, weapons)
  equip[p_name].weapons = weapons
  --block_league.update_storage(p_name)
end



function block_league.set_player_skill(p_name, s_name)
  equip[p_name].skill = s_name
  block_league.update_storage(p_name, "skill", s_name)
end
