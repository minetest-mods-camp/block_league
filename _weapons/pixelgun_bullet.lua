block_league.register_bullet("block_league:pixelgun_bullet", {
  description = "proiettile pixelgun",
  mesh = "block_league_grenade.obj",
  tiles = {"block_league_grenade.png"},
  wield_scale = {x=1.5, y=1.5, z=1.5},
  inventory_image = "block_league_grenade_icon.png",
  stack_max = 99,
  throwable_by_hand = false,
  impaling = true,
  knockback = 0,
  decrease_damage_with_distance = false,
  bullet_damage = 777,
  shootable = false,
  bullet_trail = {
    image = "block_league_pixelgun_trail.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 20,
  },



})
