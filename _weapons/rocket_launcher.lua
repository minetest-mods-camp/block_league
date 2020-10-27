
block_league.register_weapon("block_league:rocket_launcher", {
  description = S("Rocket Launcher"),
  mesh = "block_league_rocketlauncher.obj",
  tiles = {"block_league_rocketlauncher.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "block_league_rocketlauncher_icon.png",

  weap_delay = 0.8,
  weap_sound_shooting = "block_league_rocketlauncher_shoot",
  type = 2,
  continuos_fire = true,
  slow_down_when_firing = false,
  consume_bullets = false,
  launching_force = 10,
  bullet = "block_league:rocket",

})
