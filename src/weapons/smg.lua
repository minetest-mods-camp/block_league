local S = minetest.get_translator("block_league")
local dmg = 3

block_league.register_weapon("block_league:smg", {

  description = S("Submachine Gun"),
  profile_description = S("Your go-to weapon for close combat"),
  action1 = S("shoot, decrease damage with distance, @1♥", "<style color=#f66c77>" .. dmg),
  action2 = S("---"),

  mesh = "bl_smg.obj",
  tiles = {"bl_smg_texture.png"},
  wield_scale = {x=1.34, y=1.34, z=1.34},
  inventory_image = "bl_smg.png",
  crosshair = "bl_smg_crosshair.png",

  weapon_type = 1,
  magazine = 30,
  reload_time = 2,
  sound_reload = "bl_smg_reload",

  damage = dmg,
  knockback = 0,
  weapon_range = 30,
  fire_delay = 0.1,

  pierce = false,
  decrease_damage_with_distance = true,
  continuos_fire = true,

  sound_shoot = "bl_smg_shoot",
  sound_reload = "bl_smg_reload",
  bullet_trail = {
    image = "bl_smg_trail.png",
    amount = 5
  }
})
