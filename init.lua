block_league = {}
local S = minetest.get_translator("block_league")
local modpath = minetest.get_modpath("block_league")
local version = "0.3.0"

dofile(modpath .. "/GLOBALS.lua")



arena_lib.register_minigame("block_league", {
  prefix = "[Block League] ",
  hub_spawn_point = { x = 113, y = 30, z = 175 },

  teams = { S("red"), S("blue") },
  teams_color_overlay = { "red", "blue"},

  hotbar = {
    slots = 4,
    background_image = "bl_gui_hotbar.png"
  },

  time_mode = 2,

  join_while_in_progress = true,
  load_time = 6,
  celebration_time = 5,

  in_game_physics = {
    speed = block_league.SPEED,
    jump = 1.5,
    gravity = 1.15,
    sneak_glitch = true,
    new_move = true
  },
  disabled_damage_types = {"fall", "punch"},

  properties = {
    -- 1 = Touchdown
    -- 2 = Deathmatch
    mod = 1,
    score_cap = 10,
    immunity_time = 6,
    goal_red = {},
    goal_blue = {},
    waiting_room_red = {},
    waiting_room_blue = {},
    ball_spawn = {},
    min_y = 0
  },
  temp_properties = {
    weapons_disabled = true,
  },
  team_properties = {
    TDs = 0,
    kills = 0,
    deaths = 0
  },
  player_properties = {
    energy = 100,
    weapons_magazine = {}
  }
})



-- load other scripts

dofile(modpath .. "/achievements.lua")
dofile(modpath .. "/chatcmdbuilder.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/database_manager.lua")
dofile(modpath .. "/exp_manager.lua")
dofile(modpath .. "/input_manager.lua")
dofile(modpath .. "/player_manager.lua")
dofile(modpath .. "/privs.lua")

-- arena_lib
dofile(modpath .. "/bl_arena_lib/arena_manager.lua")
dofile(modpath .. "/bl_arena_lib/arena_timer.lua")
-- debug
dofile(modpath .. "/bl_debug/debug.lua")
dofile(modpath .. "/bl_debug/testkit.lua")
-- HUD
dofile(modpath .. "/bl_HUD/hud_achievements.lua")
dofile(modpath .. "/bl_HUD/hud_broadcast.lua")
dofile(modpath .. "/bl_HUD/hud_bullets.lua")
dofile(modpath .. "/bl_HUD/hud_energy.lua")
dofile(modpath .. "/bl_HUD/hud_info_panel.lua")
dofile(modpath .. "/bl_HUD/hud_inputs.lua")
dofile(modpath .. "/bl_HUD/hud_scoreboard.lua")
-- abstract weapons
dofile(modpath .. "/bl_weapons/bullets.lua")
dofile(modpath .. "/bl_weapons/weapons.lua")
dofile(modpath .. "/bl_weapons/weapons_utils.lua")
-- weapons
dofile(modpath .. "/bl_weapons/bouncer.lua")
dofile(modpath .. "/bl_weapons/grenade_launcher.lua")
dofile(modpath .. "/bl_weapons/pixelgun.lua")
dofile(modpath .. "/bl_weapons/rocket_launcher.lua")
dofile(modpath .. "/bl_weapons/sword.lua")
dofile(modpath .. "/bl_weapons/smg.lua")
-- modes
dofile(modpath .. "/bl_modes/game_main.lua")
dofile(modpath .. "/bl_modes/TD/ball.lua")
-- misc
dofile(modpath .. "/bl_misc/energy.lua")
dofile(modpath .. "/bl_misc/immunity.lua")

block_league.init_storage()

minetest.log("action", "[BLOCK_LEAGUE] Mod initialised, running version " .. version)
