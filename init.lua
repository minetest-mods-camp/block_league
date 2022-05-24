local S = minetest.get_translator("block_league")
local modpath = minetest.get_modpath("block_league")
local srcpath = modpath .. "/src"
local version = "0.5.0-dev"

block_league = {}
dofile(modpath .. "/GLOBALS.lua")



arena_lib.register_minigame("block_league", {
  prefix = "[Block League] ",

  teams = { S("orange"), S("blue") },
  teams_color_overlay = { "orange", "blue"},

  camera_offset = {
    nil,
    {x=8, y=4, z=-1}
  },

  hotbar = {
    slots = 4,
    background_image = "bl_gui_hotbar.png"
  },

  time_mode = "decremental",

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
    mode = 1,
    score_cap = 5,
    immunity_time = 6,
    goal_orange = {},
    goal_blue = {},
    waiting_room_orange = {},
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
    TDs = 0,
    points = 0,
    entering_time = 0,
    weapons_magazine = {}
  }
})



-- load other scripts

dofile(srcpath .. "/achievements.lua")
dofile(srcpath .. "/chatcmdbuilder.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/database_manager.lua")
dofile(srcpath .. "/exp_manager.lua")
dofile(srcpath .. "/input_manager.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/privs.lua")
dofile(srcpath .. "/utils.lua")

-- arena_lib
dofile(srcpath .. "/arena_lib/arena_manager.lua")
dofile(srcpath .. "/arena_lib/arena_timer.lua")
-- debug
dofile(srcpath .. "/debug/debug.lua")
dofile(srcpath .. "/debug/testkit.lua")
-- HUD
dofile(srcpath .. "/HUD/hud_achievements.lua")
dofile(srcpath .. "/HUD/hud_broadcast.lua")
dofile(srcpath .. "/HUD/hud_bullets.lua")
dofile(srcpath .. "/HUD/hud_critical.lua")
dofile(srcpath .. "/HUD/hud_energy.lua")
dofile(srcpath .. "/HUD/hud_info_panel.lua")
dofile(srcpath .. "/HUD/hud_inputs.lua")
dofile(srcpath .. "/HUD/hud_log.lua")
dofile(srcpath .. "/HUD/hud_scoreboard.lua")
dofile(srcpath .. "/HUD/hud_spectate.lua")
-- abstract weapons
dofile(srcpath .. "/weapons/bullets.lua")
dofile(srcpath .. "/weapons/weapons.lua")
dofile(srcpath .. "/weapons/weapons_utils.lua")
-- weapons
dofile(srcpath .. "/weapons/bouncer.lua")
dofile(srcpath .. "/weapons/grenade_launcher.lua")
dofile(srcpath .. "/weapons/pixelgun.lua")
dofile(srcpath .. "/weapons/rocket_launcher.lua")
dofile(srcpath .. "/weapons/sword.lua")
dofile(srcpath .. "/weapons/smg.lua")
-- modes
dofile(srcpath .. "/modes/game_main.lua")
dofile(srcpath .. "/modes/TD/ball.lua")
-- misc
dofile(srcpath .. "/misc/energy.lua")
dofile(srcpath .. "/misc/fall.lua")
dofile(srcpath .. "/misc/immunity.lua")

block_league.init_storage()

minetest.log("action", "[BLOCK_LEAGUE] Mod initialised, running version " .. version)
