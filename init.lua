block_league = {}
local S = minetest.get_translator("block_league")

dofile(minetest.get_modpath("block_league") .. "/GLOBALS.lua")



arena_lib.register_minigame("block_league", {
  prefix = "[Block League] ",
  hub_spawn_point = { x = 8, y = 6, z = 4 },

  teams = { S("red"), S("blue") },
  teams_color_overlay = { "red", "blue"},

  join_while_in_progress = true,
  celebration_time = 5,

  in_game_physics = {
    speed = block_league.SPEED,
    jump = 1.5,
    gravity = 1.15,
    sneak_glitch = true,
    new_move = true
  },
  disabled_damage_types = {"fall"},

  properties = {
    -- 1 = Touchdown
    -- 2 = Deathmatch
    mod = 1,
    score_cap = 10,
    max_energy = 100,
    immunity_time = 6,
    goal_red = {},
    goal_blue = {},
    ball_spawn = {},
    min_y = 0,
  },
  temp_properties = {
    weapons_disabled = false,
  },
  team_properties = {
    TDs = 0,
    kills = 0,
    deaths = 0
  },
  player_properties = {
    energy = 100,
    weapons_reload = {},
  }
})



-- load other scripts

dofile(minetest.get_modpath("block_league") .. "/achievements.lua")
dofile(minetest.get_modpath("block_league") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("block_league") .. "/commands.lua")
dofile(minetest.get_modpath("block_league") .. "/database_manager.lua")
dofile(minetest.get_modpath("block_league") .. "/exp_manager.lua")
dofile(minetest.get_modpath("block_league") .. "/input_manager.lua")
dofile(minetest.get_modpath("block_league") .. "/items.lua")
dofile(minetest.get_modpath("block_league") .. "/player_manager.lua")
dofile(minetest.get_modpath("block_league") .. "/privs.lua")
dofile(minetest.get_modpath("block_league") .. "/utils.lua")

-- arena_lib
dofile(minetest.get_modpath("block_league") .. "/_arena_lib/arena_manager.lua")
dofile(minetest.get_modpath("block_league") .. "/_arena_lib/arena_properties.lua")
-- HUD
dofile(minetest.get_modpath("block_league") .. "/_HUD/hud_achievements.lua")
dofile(minetest.get_modpath("block_league") .. "/_HUD/hud_broadcast.lua")
dofile(minetest.get_modpath("block_league") .. "/_HUD/hud_bullets.lua")
dofile(minetest.get_modpath("block_league") .. "/_HUD/hud_energy.lua")
dofile(minetest.get_modpath("block_league") .. "/_HUD/hud_scoreboard.lua")
dofile(minetest.get_modpath("block_league") .. "/_HUD/hud_teams_score.lua")
-- abstract weapons
dofile(minetest.get_modpath("block_league") .. "/_weapons/bullets.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/weapons.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/weapons_utils.lua")
-- weapons
dofile(minetest.get_modpath("block_league") .. "/_weapons/bouncer.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/grenade.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/grenade_launcher.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/pixelgun.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/pixelgun_bullet.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/rocket.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/rocket_launcher.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/sword.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/smg.lua")
dofile(minetest.get_modpath("block_league") .. "/_weapons/smg_bullet.lua")
-- misc
dofile(minetest.get_modpath("block_league") .. "/_misc/ball.lua")
dofile(minetest.get_modpath("block_league") .. "/_misc/energy.lua")
dofile(minetest.get_modpath("block_league") .. "/_misc/immunity.lua")

block_league.init_storage()
