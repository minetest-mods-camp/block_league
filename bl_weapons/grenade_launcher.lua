
block_league.register_weapon("block_league:grenade_launcher", {

  description = S("Grenade Launcher"),
  mesh = "bl_rocketlauncher.obj",
  tiles = {"bl_rocketlauncher.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_grenade_launcher.png",

  weapon_type = 2,

  damage = 10,
  knockback = 1,
  weap_delay = 0.8,

  pierce = false,
  decrease_damage_with_distance = false,
  slow_down_when_firing = true,
  continuos_fire = false,

  sound_shoot = "bl_rocketlauncher_shoot",
  bullet_trail = {
    image = "bl_bullet_rocket.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 20,
  },

  consume_bullets = false,


  bullet = {
    name = "grenade",

    mesh = "bl_grenade.obj",
    visual_size = {x=7, y=7, z=7},
    textures = {"bl_grenade.png"},
    collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},

    speed = 17,
    lifetime = 1.5,

    explosion_range = 4,
    explosion_damage = 16,
    explosion_texture = "bl_rocket_particle.png",

    explode_on_contact = true,
    gravity = true,

    on_destroy = block_league.grenade_explode,
    on_right_click = function(self)
      self:_destroy()
    end

  }

})
