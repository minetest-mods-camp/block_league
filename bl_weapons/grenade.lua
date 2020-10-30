block_league.register_bullet("block_league:grenade", {
  description = "grenade",
  mesh = "bl_grenade.obj",
  tiles = {"bl_grenade.png"},
  wield_scale = {x=1.5, y=1.5, z=1.5},
  inventory_image = "bl_grenade_icon.png",
  stack_max = 99,
  pierce = false,
  throwable_by_hand = true,
  bullet_damage = 10,
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
  duration = 1.5,
  shootable = true,
  bullet = {
    bullet_speed = 17,
    bullet_explosion_damage = 16,

    visual_size = {x=7, y=7, z=7},
    mesh = "bl_grenade.obj",
    bullet_explosion_texture = "bl_rocket_particle.png",
    explode_on_contact = false,
    textures = {"bl_grenade.png"},
    collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
    bullet_explosion_range = 4,
    gravity = true,
    on_destroy = block_league.grenade_explode,
    on_right_click = function(self)
      self:_destroy()
    end

  },

})
