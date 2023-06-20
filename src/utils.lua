local function stop_and_update_last_sound() end

local sounds = {}    -- KEY: p_name; VALUE: { sounds_name = handle }



function block_league.is_in_the_air(obj_ref)
  local obj_pos = obj_ref:get_pos()
  local node_beneath = vector.new(obj_pos.x, obj_pos.y - 0.4, obj_pos.z)
  local is_in_the_air = minetest.get_node(node_beneath).name == "air"

  return is_in_the_air
end



function block_league.sound_play(sound, p_name, not_overlappable)
  local handle = minetest.sound_play(sound, {to_player = p_name})

  if not_overlappable then
    stop_and_update_last_sound(p_name, sound, handle)
  end

  if arena_lib.is_player_spectated(p_name) then
    for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
      handle = minetest.sound_play(sound, {to_player = sp_name})

      if not_overlappable then
        stop_and_update_last_sound(sp_name, sound, handle)
      end
    end
  end
end



-- interrompi l'ultimo suono chiamato "sound" e lo aggiorna a quello passatogli
function stop_and_update_last_sound(p_name, sound, handle)
  sounds[p_name] = sounds[p_name] or {}

  if sounds[p_name][sound] then
    minetest.sound_stop(sounds[p_name][sound])
  end

  sounds[p_name][sound] = handle
end
