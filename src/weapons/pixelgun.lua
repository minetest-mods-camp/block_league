local S = minetest.get_translator("block_league")

block_league.register_weapon("block_league:pixelgun", {

  description = S("Pixelgun"),
  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun_texture.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_pixelgun.png",

  weapon_type = 1,

  damage = 18,
  weapon_range = 150,
  knockback = 0,
  fire_delay = 0.9,

  pierce = true,
  decrease_damage_with_distance = false,
  continuos_fire = false,

  sound_shoot = "bl_pixelgun_shoot",
  sound_reload = "bl_pixelgun_reload",
  bullet_trail = {
    image = "bl_pixelgun_trail.png",
    amount = 20,
  },

  consume_bullets = false,
  magazine = 4,
  reload_time = 4,

  zoom = {
    fov = 20,
    -- TODO
    --HUD = "",
    --sound = ""
  }
})
