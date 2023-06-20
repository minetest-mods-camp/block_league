local S = minetest.get_translator("block_league")

local dmg1      = 3
local dmg1hold  = 6.8
local dmg1air   = 3.7
local dmg2      = 7

block_league.register_weapon("block_league:sword", {

  description = S("2H Sword"),
  profile_description = S("Keep your friends close and your enemies further -Sun Tzu"),

  wield_image = "bl_sword.png",
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_sword.png",
  crosshair = "bl_sword_crosshair.png",

  weapon_type = "melee",

  --[[action1 = {
    type = "punch",
    description = S("slash, @1♥", "<style color=#f66c77>" .. dmg1),
    damage = dmg1,
    delay = 0.4,
    sound = "bl_sword_hit",
  },]]

  -- TODO: questa dovrebbe diventare action1_hold una volta che sarà possibile
  -- personalizzare l'animazione dell'oggetto tenuto in mano. Vedasi
  -- https://github.com/minetest/minetest/issues/2811
  action1 = {
    type = "punch",
    description = S("push, @1♥", "<style color=#f66c77>" .. dmg1hold),
    damage = dmg1hold,
    knockback = 40,
    delay = 1.2,
    sound = "bl_sword_hit",
  },

  --[[action1_air = {
    type = "custom",
    description = S("Dive onto the ground and stun enemies in front of you, @1♥", "<style color=#f66c77>" .. dmg1air),
    damage = dmg1air,
    -- loading_time = 0.3,
    delay = 1, -- poi abbassa a 0.7
    physics_override = "FREEZE",
    sound = "bl_sword_dash",

    on_use = function(player, weapon, action)
      local dummy = player:get_attach()
      dummy:set_velocity({x = 0, y = -16, z = 0})

      minetest.after(0.5, function()
        local ent_pos = dummy:get_pos()
        minetest.add_particlespawner({
          amount = 50,
          time = 0.6,
          minpos = ent_pos,
          maxpos = ent_pos,
          minvel = {x=-2, y=-2, z=-2},
          maxvel = {x=2, y=2, z=2},
          minsize = 1,
          maxsize = 3,
          texture = "arenalib_winparticle.png"
        })

        -- TODO: metti particellare appropriato; dannegga chi è in zona, 30° x lato

        minetest.after(0.5, function()
          dummy:remove()
        end)
      end)
    end
  },]]

  action2 = {
    type = "custom",
    description = S("dash forward, @1♥", "<style color=#f66c77>" .. dmg2),
    damage = dmg2,
    delay = 2.5,
    physics_override = { speed = 0.5, jump = 0 },
    sound = "bl_sword_dash",

    on_use = function(player, weapon, action)
      local dir = player:get_look_dir()
      local pos = player:get_pos()
      local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
      local pointed_players = block_league.get_pointed_players(player, pos_head, dir, 5, true)

      dir.y = 0

      local player_vel = player:get_velocity()
      local sprint = vector.multiply(dir,18)

      player:add_velocity(sprint)
      player_vel = vector.multiply(player_vel, -0.7)
      player:add_velocity(player_vel)

      if not pointed_players then return end
      block_league.apply_damage(player, pointed_players, weapon, action)
    end
  }
})