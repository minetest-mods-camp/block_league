local version = "0.8.0-dev"
local modpath = minetest.get_modpath("block_league")
local srcpath = modpath .. "/src"

local S = minetest.get_translator("block_league")

block_league = {}
dofile(modpath .. "/GLOBALS.lua")



arena_lib.register_minigame("block_league", {
  name = "Block League",
  prefix = "[Block League] ",
  icon = "bl_pixelgun.png",

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

  load_time = 6,
  celebration_time = 5,
  join_while_in_progress = true,
  time_mode = "decremental",

  disable_inventory = true,
  disabled_damage_types = {"fall", "punch"},
  in_game_physics = {
    speed = block_league.SPEED,
    jump = 1.5,
    gravity = 1.15,
    sneak_glitch = true,
    new_move = true
  },

  properties = {
    mode = 1,           -- 1 TD, 2 DM
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
    stamina = 100,
    stamina_max = 100,
    TDs = 0,
    kills = 0,
    points = 0,
    entering_time = 0,          -- inutilizzato, servirà prob in futuro per calcolare exp
    weapons_magazine = {},
    curr_weapon = "",
    dmg_received = {}           -- KEY: p_name, VALUE: {timestamp, dmg, weapon}
  },
  spectator_properties = {
    was_following_ball = false
  }
})



-- general
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/database_manager.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/privs.lua")
dofile(srcpath .. "/utils.lua")

-- arena_lib
dofile(srcpath .. "/arena_lib/arena_manager.lua")
dofile(srcpath .. "/arena_lib/arena_timer.lua")
-- debug
dofile(srcpath .. "/debug/testkit.lua")
-- GUI
dofile(srcpath .. "/GUI/gui_profile.lua")
-- HUD
dofile(srcpath .. "/HUD/hud_achievements.lua")
dofile(srcpath .. "/HUD/hud_broadcast.lua")
dofile(srcpath .. "/HUD/hud_critical.lua")
dofile(srcpath .. "/HUD/hud_stamina.lua")
dofile(srcpath .. "/HUD/hud_info_panel.lua")
dofile(srcpath .. "/HUD/hud_inputs.lua")
dofile(srcpath .. "/HUD/hud_log.lua")
dofile(srcpath .. "/HUD/hud_scoreboard.lua")
dofile(srcpath .. "/HUD/hud_skill.lua")
dofile(srcpath .. "/HUD/hud_spectate.lua")
dofile(srcpath .. "/HUD/hud_weapons.lua")
-- game
dofile(srcpath .. "/game/game_main.lua")
dofile(srcpath .. "/game/input_manager.lua")
dofile(srcpath .. "/game/misc/fall.lua")
dofile(srcpath .. "/game/misc/immunity.lua")
dofile(srcpath .. "/game/misc/stamina.lua")
dofile(srcpath .. "/game/TD/ball.lua")
-- player
dofile(srcpath .. "/player/achievements.lua")
dofile(srcpath .. "/player/equip.lua")
dofile(srcpath .. "/player/exp.lua")
-- skills
dofile(srcpath .. "/skills/sp+.lua")
dofile(srcpath .. "/skills/hp+.lua")
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

minetest.log("action", "[BLOCK_LEAGUE] Mod initialised, running version " .. version)
