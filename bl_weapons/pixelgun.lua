
block_league.register_weapon("block_league:pixelgun", {

  --Definizione apparenza
  description = S("pixelgun"),
  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_pixelgun_icon.png",
  weap_sound_shooting = "bl_pixelgun_shoot",
  consume_bullets = false,
  reload = 4,
  reload_delay = 4,
  type = 1,
  weap_delay = 0.9,
  slow_down_when_firing = true,
  continuos_fire = false,
  bullet = "block_league:pixelgun_bullet",

  range = 100, --Se non hitscan calcolarsi il tempo necessario per percorrere quello
              --spazio in base alla velocità
})
