
block_league.register_weapon("block_league:grenade_launcher", {
  description = S("Grenade Launcher"),
  mesh = "block_league_rocketlauncher.obj",
  tiles = {"block_league_rocketlauncher.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "block_league_grenade_launcher.png",

  weap_delay = 0.8,
  weap_sound_shooting = "block_league_rocketlauncher_shoot",
  continuos_fire = false,
  slow_down_when_firing = false,
  consume_bullets = false,
  type = 2,
  launching_force = 10,

  bullet = "block_league:grenade",

})
