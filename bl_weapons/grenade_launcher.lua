
block_league.register_weapon("block_league:grenade_launcher", {
  description = S("Grenade Launcher"),
  mesh = "bl_rocketlauncher.obj",
  tiles = {"bl_rocketlauncher.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_grenade_launcher.png",

  weap_delay = 0.8,
  weap_sound_shooting = "bl_rocketlauncher_shoot",
  continuos_fire = false,
  slow_down_when_firing = false,
  consume_bullets = false,
  type = 2,
  launching_force = 10,

  bullet = "block_league:grenade",

})
