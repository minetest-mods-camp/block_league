local S = minetest.get_translator("block_league")

local function reset_meta() end



arena_lib.on_load("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do

    reset_meta(pl_name)

    block_league.HUD_broadcast_create(pl_name)
    block_league.scoreboard_create(arena, pl_name)
    block_league.HUD_teams_score_create(pl_name)
    block_league.energy_create(arena, pl_name)


    panel_lib.get_panel(pl_name, "blockleague_teams_score"):show()
    panel_lib.get_panel(pl_name, "blockleague_energy"):show()

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

function block_league.add_default_weapons(inv, arena)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun", "block_league:bouncer"}
  for i, weapon_name in pairs(default_weapons) do
    inv:add_item("main", ItemStack(weapon_name))
  end
end

function block_league.remove_default_weapons(inv, arena)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun", "block_league:bouncer"}
  for i, weapon_name in pairs(default_weapons) do
    inv:remove_item("main", ItemStack(weapon_name .. "99"))
  end
end


arena_lib.on_start("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do

    local player = minetest.get_player_by_name(pl_name)
    block_league.add_default_weapons(player:get_inventory(), arena)
    block_league.weapons_hud_create(pl_name)
    panel_lib.get_panel(pl_name, "bullets_hud"):show()

    player:set_physics_override({
              speed = arena.high_speed,
              jump = 1.5,
              gravity = 1.15,
              sneak_glitch = true,
              new_move = true
              })

    minetest.sound_play("block_league_voice_fight", {
      to_player = pl_name,
    })

    player:set_armor_groups({immortal = nil})

  end

  if arena.prototipo_spawn ~= nil then
    local pos1 = {x = arena.prototipo_spawn.x - 1, y = arena.prototipo_spawn.y - 1, z = arena.prototipo_spawn.z - 1}
    local pos2 = {x = arena.prototipo_spawn.x + 1, y = arena.prototipo_spawn.y + 1, z = arena.prototipo_spawn.z + 1}
    --minetest.load_area(pos1, pos2)
    --minetest.emerge_area(pos1, pos2)
    minetest.forceload_block(pos1, pos2)
    minetest.after(3, function()
      local ent = minetest.add_entity(arena.prototipo_spawn,"block_league:prototipo",arena.name)
    end)
  end

  block_league.energy_refill(arena)

end)



arena_lib.on_join("block_league", function(p_name, arena)

  reset_meta(p_name)

  local player = minetest.get_player_by_name(p_name)

  block_league.HUD_broadcast_create(p_name)
  block_league.scoreboard_create(arena, p_name)
  block_league.HUD_teams_score_create(p_name)
  block_league.energy_create(arena, p_name)

  panel_lib.get_panel(p_name, "blockleague_teams_score"):show()
  panel_lib.get_panel(p_name, "blockleague_energy"):show()

  block_league.add_default_weapons(player:get_inventory(), arena)
  block_league.weapons_hud_create(p_name)
  panel_lib.get_panel(p_name, "bullets_hud"):show()

  player:set_physics_override({
            speed = arena.high_speed,
            jump = 1.5,
            gravity = 1.15,
            sneak_glitch = true,
            new_move = true
            })

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

      local inv = minetest.get_player_by_name(pl_name):get_inventory()

      block_league.remove_default_weapons(inv, arena)
      inv:add_item("main", ItemStack("block_league:match_over"))

      local player = minetest.get_player_by_name(pl_name)
      player:set_armor_groups({immortal=1})

      panel_lib.get_panel(pl_name, "blockleague_scoreboard"):show()
    end
  end)
end)



arena_lib.on_end("block_league", function(arena, players)

  for pl_name, stats in pairs(players) do

    --local stats = panel_lib.get_panel(pl_name, "blockleague_stats")
    local scoreboard = panel_lib.get_panel(pl_name, "blockleague_scoreboard")
    local team_score = panel_lib.get_panel(pl_name, "blockleague_teams_score")

    --stats:remove()
    scoreboard:remove()
    team_score:remove()
    panel_lib.get_panel(pl_name, "bullets_hud"):remove()
    block_league.HUD_broadcast_remove(pl_name)
    panel_lib.get_panel(pl_name, "blockleague_energy"):remove()

    block_league.update_storage(pl_name)

    local player = minetest.get_player_by_name(pl_name)
    player:set_armor_groups({immortal = nil})

    -- se non c'è hub_manager, resetto la fisica
    if not minetest.get_modpath("hub_manager") then
      minetest.get_player_by_name(pl_name):set_physics_override({
                speed = 1,
                jump = 1,
                gravity = 1,
                sneak_glitch = false
                })
    end
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

  --local stats = panel_lib.get_panel(p_name, "blockleague_stats")
  local scoreboard = panel_lib.get_panel(p_name, "blockleague_scoreboard")
  local team_score = panel_lib.get_panel(p_name, "blockleague_teams_score")

  --stats:remove()
  scoreboard:remove()
  team_score:remove()
  panel_lib.get_panel(p_name, "bullets_hud"):remove()
  panel_lib.get_panel(p_name, "blockleague_energy"):remove()
  block_league.HUD_broadcast_remove(p_name)

  local player = minetest.get_player_by_name(p_name)

  player:set_armor_groups({immortal = nil})
  player:get_meta():set_int("blockleague_has_ball", 0)

  -- se non c'è hub_manager, resetto la fisica
  if not minetest.get_modpath("hub_manager") then
    minetest.get_player_by_name(p_name):set_physics_override({
              speed = 1,
              jump = 1,
              gravity = 1,
              sneak_glitch = false
              })
  end
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function reset_meta(p_name)

  local player = minetest.get_player_by_name(p_name)

  player:get_meta():set_int("blockleague_has_ball", 0)
  player:get_meta():set_int("blockleague_weap_delay", 0)
  player:get_meta():set_int("blockleague_weap_secondary_delay", 0)
  player:get_meta():set_int("blockleague_bouncer_delay", 0)
  player:get_meta():set_int("blockleague_death_delay", 0)
  player:get_meta():set_int("reloading", 0)


end
