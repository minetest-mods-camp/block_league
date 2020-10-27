block_league.register_bullet("block_league:smg_bullet", {
  description = S("Proiettile SMG"),
  wield_image = "block_league_smg.png",
  wield_scale = {x=1, y=1, z=1},
  inventory_image = "block_league_smg.png",

  stack_max = 99,
  throwable_by_hand = false,
  impaling = false,
  knockback = 0,
  decrease_damage_with_distance = true,
  bullet_damage = 3,
  shootable = false,
  bullet_trail = {
    image = "block_league_smg_trail.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 5,
  },



})
