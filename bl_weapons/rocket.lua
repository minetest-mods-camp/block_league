block_league.register_bullet("block_league:rocket",{
  description = "rocket",
  mesh = "bl_rocket.obj",
  wield_scale = {x=1, y=1, z=1},
  tiles = {"bl_bullet_rocket.png"},
  stack_max = 99,
   -- {xmin, ymin, zmin, xmax, ymax, zmax}
  bullet_damage = 10,
  throwable_by_hand = false,
  duration = 5,
  impaling = false,
  decrease_damage_with_distance = false,
  bullet_trail = {
    image = "bl_bullet_rocket.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 20,
  },
  knockback = 0,
  shootable = true,

  bullet = {

    mesh = "bl_rocket.obj",
    visual_size = {x=1, y=1, z=1},
    textures = {"bl_bullet_rocket.png"},

    bullet_explosion_texture = "bl_rocket_particle.png",
    bullet_speed = 30,
    collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
    bullet_explosion_range = 4,
    bullet_explosion_damage = 10,
    on_destroy = block_league.explode,
    on_right_click = function(self)
      self:_destroy()
    end,
    explode_on_contact = true,
    gravity = false,
  }

})
