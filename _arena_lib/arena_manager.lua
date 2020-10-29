local S = minetest.get_translator("block_league")

local function reset_meta() end



arena_lib.on_load("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do

    reset_meta(pl_name)

    block_league.HUD_broadcast_create(pl_name)
    block_league.scoreboard_create(arena, pl_name)
    block_league.HUD_teams_score_create(pl_name)
    block_league.energy_create(arena, pl_name)

    panel_lib.get_panel(pl_name, "bl_teams_score"):show()
    panel_lib.get_panel(pl_name, "bl_energy"):show()

    minetest.sound_play("block_league_voice_countdown", {
      to_player = pl_name,
    })

    -- non crea E aggiorna l'HUD al tempo stesso, dacché l'after...
    minetest.after(0.1, function()
      block_league.energy_update(arena, pl_name)
    end)

  end

  minetest.after(0.01, function()
    block_league.scoreboard_update(arena)
  end)

end)



arena_lib.on_start("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)

    block_league.add_default_weapons(player:get_inventory(), arena)
    block_league.weapons_hud_create(pl_name)
    panel_lib.get_panel(pl_name, "bullets_hud"):show()

    minetest.sound_play("block_league_voice_fight", {
      to_player = pl_name,
    })

    player:set_armor_groups({immortal = nil})
  end

  block_league.round_start(arena)
  block_league.energy_refill_loop(arena)

end)



arena_lib.on_join("block_league", function(p_name, arena)

  reset_meta(p_name)

  local player = minetest.get_player_by_name(p_name)

  block_league.HUD_broadcast_create(p_name)
  block_league.scoreboard_create(arena, p_name)
  block_league.HUD_teams_score_create(p_name)
  block_league.energy_create(arena, p_name)

  panel_lib.get_panel(p_name, "bl_teams_score"):show()
  panel_lib.get_panel(p_name, "bl_energy"):show()

  block_league.add_default_weapons(player:get_inventory(), arena)
  block_league.weapons_hud_create(p_name)
  panel_lib.get_panel(p_name, "bullets_hud"):show()

  minetest.sound_play("block_league_voice_fight", {
    to_player = p_name,
  })

  player:set_armor_groups({immortal = nil})

  minetest.after(0.01, function()
    block_league.energy_update(arena, p_name)
    block_league.scoreboard_update(arena)
    block_league.HUD_teams_score_update(arena, p_name, arena.players[p_name].teamID)

  end)

end)



arena_lib.on_celebration("block_league", function(arena, winner_name)

  --block_league.add_xp(winner_name, 50)

  minetest.after(0.01, function()
    for pl_name, stats in pairs(arena.players) do

      local player = minetest.get_player_by_name(pl_name)

      block_league.remove_default_weapons(player:get_inventory(), arena)
      player:set_armor_groups({immortal=1})

      panel_lib.get_panel(pl_name, "bl_scoreboard"):show()
    end
  end)
end)



arena_lib.on_end("block_league", function(arena, players)

  for pl_name, stats in pairs(players) do

    local scoreboard = panel_lib.get_panel(pl_name, "bl_scoreboard")
    local team_score = panel_lib.get_panel(pl_name, "bl_teams_score")

    scoreboard:remove()
    team_score:remove()
    panel_lib.get_panel(pl_name, "bullets_hud"):remove()
    block_league.HUD_broadcast_remove(pl_name)
    panel_lib.get_panel(pl_name, "bl_energy"):remove()

    block_league.update_storage(pl_name)

    local player = minetest.get_player_by_name(pl_name)

    player:set_armor_groups({immortal = nil})
  end
end)



arena_lib.on_death("block_league", function(arena, p_name, reason)

  -- se muoio suicida, perdo una kill
  if reason.type == "fall" or reason.player_name == p_name then

    local p_stats = arena.players[p_name]

    p_stats.kills = p_stats.kills - 1
    local team = arena.teams[p_stats.teamID]
    team.deaths = team.deaths + 1
    block_league.scoreboard_update(arena)
    block_league.subtract_exp(p_name, 10)
  end

end)



arena_lib.on_quit("block_league", function(arena, p_name)

  --local stats = panel_lib.get_panel(p_name, "bl_stats")
  local scoreboard = panel_lib.get_panel(p_name, "bl_scoreboard")
  local team_score = panel_lib.get_panel(p_name, "bl_teams_score")

  --stats:remove()
  scoreboard:remove()
  team_score:remove()
  panel_lib.get_panel(p_name, "bullets_hud"):remove()
  panel_lib.get_panel(p_name, "bl_energy"):remove()
  block_league.HUD_broadcast_remove(p_name)

  local player = minetest.get_player_by_name(p_name)

  player:set_armor_groups({immortal = nil})
  player:get_meta():set_int("bl_has_ball", 0)

end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function reset_meta(p_name)

  local player = minetest.get_player_by_name(p_name)

  player:get_meta():set_int("bl_has_ball", 0)
  player:get_meta():set_int("bl_weap_delay", 0)
  player:get_meta():set_int("bl_weap_secondary_delay", 0)
  player:get_meta():set_int("bl_bouncer_delay", 0)
  player:get_meta():set_int("bl_death_delay", 0)
  player:get_meta():set_int("bl_reloading", 0)

end
