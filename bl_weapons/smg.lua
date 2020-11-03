local S = minetest.get_translator("block_league")

block_league.register_weapon("block_league:smg", {

  description = S("Submachine Gun"),
  wield_image = "bl_smg.png",
  wield_scale = {x=1, y=1, z=1},
  inventory_image = "bl_smg.png",

  weapon_type = 1,

  damage = 3,
  range = 30,
  knockback = 0,
  weap_delay = 0.1,

  pierce = false,
  decrease_damage_with_distance = true,
  slow_down_when_firing = true,
  continuos_fire = true,

  sound_shoot = "bl_smg_shoot",
  bullet_trail = {
    image = "bl_smg_trail.png",
    amount = 5
  },

  consume_bullets = false,
  magazine = 30,
  reload_time = 2

})
