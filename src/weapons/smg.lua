local S = minetest.get_translator("block_league")
local dmg1 = 3

block_league.register_weapon("block_league:smg", {

  description = S("Submachine Gun"),
  profile_description = S("Your go-to weapon for close combat"),

  mesh = "bl_smg.obj",
  tiles = {"bl_smg_texture.png"},
  wield_scale = {x=1.34, y=1.34, z=1.34},
  inventory_image = "bl_smg.png",
  crosshair = "bl_smg_crosshair.png",

  weapon_type = "gun",
  magazine = 30,
  reload_time = 2,
  sound_reload = "bl_smg_reload",

  action1 = {
    type = "raycast",
    description = S("shoot, decrease damage with distance, @1♥", "<style color=#f66c77>" .. dmg1),
    damage = dmg1,
    range = 30,
    delay = 0.1,
    --fire_spread = 0.2,

    --loading_time = 0, -- altri parametri che potrebbero servire ad altre armi

    decrease_damage_with_distance = true,
    continuous_fire = true,

    sound = "bl_smg_shoot",
    trail = {
      image = "bl_smg_trail.png",
      amount = 5
    },
  },

  --[[action2 = {
    type = "raycast",
    description = "TODO",
    damage = 5,
    range = 20,
    delay = 0.5,
    ammo_per_use = 3,
    --TODO: booleano per far critici o meno?

    continuous_fire = true,

    sound = "bl_smg_shoot",
    trail = {
      image = "bl_smg_trail.png",
      amount = 5
    },
  }]]
})
