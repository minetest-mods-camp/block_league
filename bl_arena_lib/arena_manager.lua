local S = minetest.get_translator("block_league")

local function reset_meta() end
local function create_and_show_HUD() end
local function remove_HUD() end
local function equip_weapons() end



arena_lib.on_load("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do
    reset_meta(pl_name)
    equip_weapons(pl_name, arena)
    create_and_show_HUD(arena, pl_name)

    minetest.sound_play("bl_voice_countdown", {to_player = pl_name})
  end

  minetest.after(0.01, function()
    block_league.scoreboard_update(arena)
  end)

end)



arena_lib.on_start("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do
    minetest.get_player_by_name(pl_name):set_armor_groups({immortal = nil})
    minetest.sound_play("bl_voice_fight", {to_player = pl_name})
  end

  block_league.round_start(arena)
  block_league.energy_refill_loop(arena)

end)



arena_lib.on_join("block_league", function(p_name, arena)

  reset_meta(p_name)
  equip_weapons(p_name, arena)
  create_and_show_HUD(arena, p_name)

  minetest.get_player_by_name(p_name):set_armor_groups({immortal = nil})

  minetest.sound_play("bl_voice_fight", {to_player = p_name})

  minetest.after(0.01, function()
    block_league.scoreboard_update(arena)
    block_league.teams_score_update(arena, p_name, arena.players[p_name].teamID)
  end)
end)



arena_lib.on_celebration("block_league", function(arena, winner_name)

  --block_league.add_xp(winner_name, 50)
  arena.weapons_disabled = true

  for pl_name, stats in pairs(arena.players) do
    minetest.get_player_by_name(pl_name):set_armor_groups({immortal=1})
    panel_lib.get_panel(pl_name, "bl_scoreboard"):show()
  end
end)



arena_lib.on_end("block_league", function(arena, players)

  for pl_name, stats in pairs(players) do

    remove_HUD(pl_name)
    minetest.get_player_by_name(pl_name):set_armor_groups({immortal = nil})

    block_league.update_storage(pl_name)
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
  end
end)



arena_lib.on_quit("block_league", function(arena, p_name)

  remove_HUD(p_name)

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



function create_and_show_HUD(arena, p_name)
  block_league.broadcast_create(p_name)
  block_league.scoreboard_create(arena, p_name)
  block_league.teams_score_create(p_name)
  block_league.energy_create(arena, p_name)
  block_league.bullets_hud_create(p_name)

  panel_lib.get_panel(p_name, "bl_teams_score"):show()
  panel_lib.get_panel(p_name, "bl_energy"):show()
  panel_lib.get_panel(p_name, "bl_bullets"):show()
end



function remove_HUD(p_name)
  panel_lib.get_panel(p_name, "bl_scoreboard"):remove()
  panel_lib.get_panel(p_name, "bl_teams_score"):remove()
  panel_lib.get_panel(p_name, "bl_bullets"):remove()
  panel_lib.get_panel(p_name, "bl_energy"):remove()
  block_league.HUD_broadcast_remove(p_name)
end



function equip_weapons(p_name, arena)

  local inv = minetest.get_player_by_name(p_name):get_inventory()

  -- TODO: ottenere armi in database giocatori, dato che potranno cambiarle
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun"}

  for i, weapon_name in pairs(default_weapons) do
    local magazine = minetest.registered_nodes[weapon_name].magazine

    if magazine then
      arena.players[p_name].weapons_magazine[weapon_name] = magazine
    end
    inv:add_item("main", ItemStack(weapon_name))
  end

  inv:add_item("main", ItemStack("block_league:bouncer"))
end
