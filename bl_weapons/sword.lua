block_league.register_weapon("block_league:sword", {

  description = "Spada",
  inventory_image = "bl_sword.png",
  wield_scale = {x=1.3, y=1.3, z=1.3},
  wield_image = "bl_sword.png",

  weap_delay = 2,
  weap_secondary_delay = 3,

  type = 3,
  weap_damage = 7,
  knockback = 40,

  on_right_click = function(arena, name, def, itemstack, user, pointed_thing)

    local dir = user:get_look_dir()
    local pos = user:get_pos()
    local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
    local pointed_players = block_league.get_pointed_players(pos_head, dir, 5, user, nil, true)

    dir.y = 0

    local player_vel = user:get_player_velocity()
    local sprint = vector.multiply(dir,18)

    user:add_player_velocity(sprint)
    player_vel = vector.multiply(player_vel, -0.7)
    user:add_player_velocity(player_vel)
    user:set_physics_override({
      speed = 0.5,
      jump = 0
    })

    minetest.after(2.5, function()
      if not arena_lib.is_player_in_arena(user:get_player_name(), "block_league") then return end
      local vel = user:get_meta():get_int("bl_has_ball") == 0 and block_league.SPEED or block_league.SPEED_LOW
        user:set_physics_override({
          speed = vel,
          jump = 1.5
        })
    end)

    if not pointed_players then return end
    block_league.apply_damage(user, pointed_players, def.weap_damage, def.knockback, false)

  end,
})
