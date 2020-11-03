local S = minetest.get_translator("block_league")

block_league.register_weapon("block_league:pixelgun", {

  description = S("Pixelgun"),
  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_pixelgun_icon.png",

  weapon_type = 1,

  damage = 999,
  weapon_range = 100,
  knockback = 0,
  fire_delay = 0.9,

  pierce = true,
  decrease_damage_with_distance = false,
  slow_down_when_firing = true,
  continuos_fire = false,

  sound_shoot = "bl_pixelgun_shoot",
  bullet_trail = {
    image = "bl_pixelgun_trail.png",
    amount = 20,
  },

  consume_bullets = false,
  magazine = 4,
  reload_time = 4,

})
