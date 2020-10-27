
block_league.register_weapon("block_league:smg", {

  description = S("Sub Machine Gun"),
  wield_image = "block_league_smg.png",
  wield_scale = {x=1, y=1, z=1},
  inventory_image = "block_league_smg.png",

  weap_sound_shooting = "block_league_smg_shoot",
  type = 1,
  weap_delay = 0.1,
  slow_down_when_firing = true,
  continuos_fire = true,
  bullet = "block_league:smg_bullet",

  consume_bullets = false,
  reload = 30,
  reload_delay = 2,

  range = 30, --Se non hitscan calcolarsi il tempo necessario per percorrere quello
              --spazio in base alla velocità
})
