local S = minetest.get_translator("block_league")
local dmg = 18

block_league.register_weapon("block_league:pixelgun", {

  description = S("Pixelgun"),
  profile_description = S("Sniping weapon: you'll never be too far away"),

  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun_texture.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_pixelgun.png",
  crosshair = "bl_pixelgun_crosshair.png",

  weapon_type = "snipe",
  magazine = 4,
  reload_time = 4,
  sound_reload = "bl_pixelgun_reload",

  action1 = {
    type = "raycast",
    description = S("piercing shot, @1♥", "<style color=#f66c77>" .. dmg),
    damage = dmg,
    range = 150,
    delay = 0.9,
    --load_time = 2,

    --attack_on_release = true, -- TODO: da implementare. Usa loading_time. Serve anche https://github.com/minetest/minetest/issues/13581
    pierce = true,

    sound = "bl_pixelgun_shoot",
    trail = {
      image = "bl_pixelgun_trail.png",
      amount = 20,
    },
  },

  action2 = {
    type = "zoom",
    description = S("zoom"),
    fov = 20,
    -- TODO
    --HUD = "",
    --sound_in = "",
    --sound_out = "" (facoltativo)
  }
})
