local function load_ball() end



function block_league.round_start(arena)
    for p_name, stats in pairs(arena.players) do

      local player = minetest.get_player_by_name(p_name)

      player:set_hp(20)
      arena.players[p_name].energy = 100
      block_league.energy_update(arena, p_name)

      block_league.refill_weapons(arena, p_name)
      player:get_meta():set_int("bl_reloading", 0)
      player:get_meta():set_int("bl_death_delay", 0)

      player:set_physics_override({
        speed = block_league.SPEED,
        jump = 1.5
      })
      player:set_pos(arena_lib.get_random_spawner(arena, stats.teamID))

      minetest.sound_play("bl_voice_fight", {to_player = p_name})
    end

  if arena.mod == 1 then
    load_ball(arena)
  end

  arena.weapons_disabled = false
end



function block_league.refill_weapons(arena, p_name)
  --TODO avere una tabella  per giocatore che tenga traccia delle armi equipaggiate
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun"}

  for i, weapon_name in pairs(default_weapons) do
    local magazine = minetest.registered_nodes[weapon_name].magazine

    if magazine then
      arena.players[p_name].weapons_magazine[weapon_name] = magazine
      block_league.weapons_hud_update(arena, p_name, weapon_name, magazine)
    end
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function load_ball(arena)
  minetest.forceload_block(arena.ball_spawn, true)
  minetest.add_entity(arena.ball_spawn,"block_league:ball",arena.name)
end
