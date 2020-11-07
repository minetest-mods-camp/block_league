local S = minetest.get_translator("block_league")

local function reset_meta() end
local function create_and_show_HUD() end
local function remove_HUD() end
local function equip_weapons() end



arena_lib.on_load("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do
    reset_meta(pl_name)
    equip_weapons(arena, pl_name)
    create_and_show_HUD(arena, pl_name)
    block_league.refill_weapons(arena, pl_name)

    minetest.sound_play("bl_voice_countdown", {to_player = pl_name})
  end

  minetest.after(0.01, function()
    block_league.info_panel_update(arena)
  end)

end)



arena_lib.on_start("block_league", function(arena)
  block_league.round_start(arena)
  block_league.energy_refill_loop(arena)
end)



arena_lib.on_join("block_league", function(p_name, arena)

  reset_meta(p_name)
  equip_weapons(arena, p_name)
  create_and_show_HUD(arena, p_name)
  block_league.refill_weapons(arena, p_name)

  minetest.sound_play("bl_voice_fight", {to_player = p_name})

  minetest.after(0.01, function()
    block_league.info_panel_update(arena)
    block_league.scoreboard_update(arena, p_name, arena.players[p_name].teamID)
  end)
end)



arena_lib.on_celebration("block_league", function(arena, winner_name)

  --block_league.add_xp(winner_name, 50)
  arena.weapons_disabled = true

  for pl_name, stats in pairs(arena.players) do
    minetest.get_player_by_name(pl_name):get_meta():set_int("bl_immunity", 1)
    panel_lib.get_panel(pl_name, "bl_info_panel"):show()
  end
end)



arena_lib.on_end("block_league", function(arena, players)

  for pl_name, stats in pairs(players) do

    remove_HUD(pl_name)
    reset_meta(pl_name)

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
    block_league.info_panel_update(arena)
  end
end)



arena_lib.on_quit("block_league", function(arena, p_name)
  --[[TODO: waiting for 5.4 to fix a few bugs
  if minetest.get_player_by_name(p_name):get_children()[1] then
    minetest.get_player_by_name(p_name):get_children()[1]:get_luaentity():detach()
  end]]

  minetest.after(0, function()
    block_league.info_panel_update(arena)
  end)

  remove_HUD(p_name)
  reset_meta(p_name)
end)



arena_lib.on_disconnect("block_league", function(arena, p_name)

  minetest.after(0, function()
    block_league.info_panel_update(arena)
  end)

  remove_HUD(p_name)
  reset_meta(p_name)
end)


--[[TODO: same as before
arena_lib.on_disconnect("block_league", function(arena, p_name)
  if minetest.get_player_by_name(p_name):get_children()[1] then
    minetest.get_player_by_name(p_name):get_children()[1]:get_luaentity():detach()
  end
end)]]





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function reset_meta(p_name)

  local p_meta = minetest.get_player_by_name(p_name):get_meta()

  p_meta:set_int("bl_has_ball", 0)
  p_meta:set_int("bl_weap_delay", 0)
  p_meta:set_int("bl_weap_secondary_delay", 0)
  p_meta:set_int("bl_bouncer_delay", 0)
  p_meta:set_int("bl_death_delay", 0)
  p_meta:set_int("bl_immunity", 0)
  p_meta:set_int("bl_reloading", 0)

end



function create_and_show_HUD(arena, p_name)
  block_league.broadcast_create(p_name)
  block_league.info_panel_create(arena, p_name)
  block_league.scoreboard_create(p_name)
  block_league.energy_create(arena, p_name)
  block_league.bullets_hud_create(p_name)

  panel_lib.get_panel(p_name, "bl_scoreboard"):show()
  panel_lib.get_panel(p_name, "bl_energy"):show()
  panel_lib.get_panel(p_name, "bl_bullets"):show()
end



function remove_HUD(p_name)
  panel_lib.get_panel(p_name, "bl_info_panel"):remove()
  panel_lib.get_panel(p_name, "bl_scoreboard"):remove()
  panel_lib.get_panel(p_name, "bl_bullets"):remove()
  panel_lib.get_panel(p_name, "bl_energy"):remove()
  block_league.HUD_broadcast_remove(p_name)
end



function equip_weapons(arena, p_name)

  --TODO avere una tabella  per giocatore che tenga traccia delle armi equipaggiate
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun"}
  local inv = minetest.get_player_by_name(p_name):get_inventory()

  for i, weapon_name in pairs(default_weapons) do
    inv:add_item("main", ItemStack(weapon_name))
  end
  inv:add_item("main", ItemStack("block_league:bouncer"))
end
