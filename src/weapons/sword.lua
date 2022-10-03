local S = minetest.get_translator("block_league")

block_league.register_weapon("block_league:sword", {

  description = S("2H Sword"),
  wield_image = "bl_sword.png",
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_sword.png",

  weapon_type = 3,

  damage = 7,
  knockback = 40,
  fire_delay = 1.4,
  weap_secondary_delay = 3,
  range = 6,

  sound_shoot = "bl_sword_hit",

  on_right_click = function(arena, weapon, user, pointed_thing)

    local p_meta = user:get_meta()

    if p_meta:get_int("bl_reloading") == 1 or
       p_meta:get_int("bl_is_shooting") == 1
       then return end

    local p_name = user:get_player_name()

    block_league.sound_play("bl_sword_dash", p_name)
    p_meta:set_int("bl_is_speed_locked", 1)

    local dir = user:get_look_dir()
    local pos = user:get_pos()
    local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
    local pointed_players = block_league.get_pointed_players(pos_head, dir, 5, user, nil, true)

    dir.y = 0

    local player_vel = user:get_velocity()
    local sprint = vector.multiply(dir,18)

    user:add_velocity(sprint)
    player_vel = vector.multiply(player_vel, -0.7)
    user:add_velocity(player_vel)
    user:set_physics_override({
      speed = 0.5,
      jump = 0
    })

    minetest.after(2.5, function()
      if not arena_lib.is_player_in_arena(p_name, "block_league") then return end

      local vel

      if arena.players[p_name].stamina > 0 then
        if p_meta:get_int("bl_reloading") == 1 or p_meta:get_int("bl_is_shooting") == 1 then
          vel = block_league.SPEED_LOW
        else
          vel = block_league.SPEED
        end
      else
        vel = block_league.SPEED_LOW
      end

      user:set_physics_override({
        speed = vel,
        jump = 1.5
      })

      user:get_meta():set_int("bl_is_speed_locked", 0)
    end)

    if not pointed_players then return end
    block_league.apply_damage(user, pointed_players, weapon, false)

  end,
})
