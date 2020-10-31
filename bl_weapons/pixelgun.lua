
block_league.register_weapon("block_league:pixelgun", {

  description = S("pixelgun"),
  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_pixelgun_icon.png",

  type = 1,

  damage = 999,
  knockback = 0,
  weap_delay = 0.9,

  pierce = true,
  decrease_damage_with_distance = false,
  slow_down_when_firing = true,
  continuos_fire = false,

  weap_sound_shooting = "bl_pixelgun_shoot",
  bullet_trail = {
    image = "bl_pixelgun_trail.png",
    amount = 20,
  },

  consume_bullets = false,
  magazine = 4,
  reload_time = 4,

  range = 100, --Se non hitscan calcolarsi il tempo necessario per percorrere quello
              --spazio in base alla velocità
})
