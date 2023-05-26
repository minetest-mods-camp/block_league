local S = minetest.get_translator("block_league")
local dmg = 18

block_league.register_weapon("block_league:pixelgun", {

  description = S("Pixelgun"),
  profile_description = S("Sniping weapon: you'll never be too far away") .. "\n\n"
    .. S("LMB: shoot @1♥", "<style color=#7a9090>" .. dmg) .. "</style>\n"
    .. S("RMB: zoom"),

  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun_texture.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_pixelgun.png",
  crosshair = "bl_pixelgun_crosshair.png",

  weapon_type = 1,

  damage = dmg,
  knockback = 0,
  weapon_range = 150,
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

  magazine = 4,
  reload_time = 4,

  zoom = {
    fov = 20,
    -- TODO
    --HUD = "",
    --sound = ""
  }
})
