local equip = {}             -- KEY p_name, INDEX weapons = { 1 = w_name, 2 = w_name, 3 = w_name}, --TODO skill = ... }

--TODO: in futuro verranno aggiunte nuove armi, e questa classe permetterà di gestirle

function block_league.init_equip(p_name)
  equip[p_name] = {}
end



function block_league.get_player_weapons(p_name)
  return equip[p_name].weapons
end



function block_league.set_player_weapons(p_name, weapons)
  equip[p_name].weapons = weapons
end
