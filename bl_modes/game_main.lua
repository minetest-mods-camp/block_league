local function load_ball() end



function block_league.round_start(arena)
    for p_name, stats in pairs(arena.players) do

      local player = minetest.get_player_by_name(p_name)

      player:set_hp(20)
      arena.players[p_name].energy = 100

      player:get_meta():set_int("bl_reloading", 0)
      panel_lib.get_panel(p_name, "bullets_hud"):remove()

      arena.players[p_name].weapons_reload = {}
      block_league.weapons_hud_create(p_name)
      panel_lib.get_panel(p_name, "bullets_hud"):show()

      block_league.energy_update(arena, p_name)
      player:set_pos(arena_lib.get_random_spawner(arena, stats.teamID))
    end

  if arena.mod == 1 then
    load_ball(arena)
  end

  arena.weapons_disabled = false
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function load_ball(arena)
  local pos1 = {x = arena.ball_spawn.x - 1, y = arena.ball_spawn.y - 1, z = arena.ball_spawn.z - 1}
  local pos2 = {x = arena.ball_spawn.x + 1, y = arena.ball_spawn.y + 1, z = arena.ball_spawn.z + 1}

  minetest.forceload_block(pos1, pos2)
  minetest.add_entity(arena.ball_spawn,"block_league:ball",arena.name)
end
