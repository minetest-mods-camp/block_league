local S = minetest.get_translator("block_league")

block_league.register_weapon("block_league:rocket_launcher", {

  description = S("Rocket Launcher"),
  mesh = "bl_rocketlauncher.obj",
  tiles = {"bl_rocketlauncher.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_rocketlauncher_icon.png",

  weapon_type = 2,

  damage = 10,
  knocback = 0,
  fire_delay = 0.8,

  pierce = false,
  decrease_damage_with_distance = false,
  continuos_fire = true,

  sound_shoot = "bl_rocketlauncher_shoot",
  bullet_trail = {
    image = "bl_bullet_rocket.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 20,
  },


  bullet = {
    name = "rocket",

    mesh = "bl_rocket.obj",
    visual_size = {x=1, y=1, z=1},
    textures = {"bl_bullet_rocket.png"},
    collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},

    speed = 30,
    lifetime = 5,

    explosion_range = 4,
    explosion_damage = 10,
    explosion_texture = "bl_rocket_particle.png",

    explode_on_contact = true,
    gravity = false,

    on_destroy = block_league.explode,
    on_right_click = function(self)
      self:_destroy()
    end
  },

})
