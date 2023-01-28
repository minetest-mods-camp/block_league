local S = minetest.get_translator("block_league")
local dmg = 7

block_league.register_weapon("block_league:sword", {

  description = S("2H Sword"),
  profile_description = S("Keep your friends close and your enemies further -Sun Zhu") .. "\n\n"
    .. S("LMB: push @1♥", "<style color=#7a9090>" .. dmg)  .. "</style>\n"
    .. S("RMB: dash @1♥", "<style color=#7a9090>" .. dmg),

  wield_image = "bl_sword.png",
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_sword.png",
  crosshair = "bl_sword_crosshair.png",

  weapon_type = 3,

  damage = dmg,
  knockback = 40,
  fire_delay = 1.2,
  weap_secondary_delay = 2.5,
  range = 6,

  sound_shoot = "bl_sword_hit",

  on_right_click = function(arena, weapon, user, pointed_thing)
    local p_meta = user:get_meta()

    if p_meta:get_int("bl_reloading") == 1 or
       p_meta:get_int("bl_is_shooting") == 1
       then return end

    local p_name = user:get_player_name()
    local w_name = weapon.name

    block_league.sound_play("bl_sword_dash", p_name)
    p_meta:set_int("bl_is_speed_locked", 1)

    block_league.HUD_weapons_update(arena, p_name, w_name, true)
    block_league.HUD_crosshair_update(p_name, w_name, true)

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

      local p_data = arena.players[p_name]
      local vel

      if p_data.stamina > 0 then
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

      local curr_weap = p_data.current_weapon

      block_league.HUD_weapons_update(arena, p_name, w_name)
      block_league.HUD_crosshair_update(p_name, curr_weap, false)

      user:get_meta():set_int("bl_is_speed_locked", 0)
    end)

    if not pointed_players then return end
    block_league.apply_damage(user, pointed_players, weapon, false)
  end
})
