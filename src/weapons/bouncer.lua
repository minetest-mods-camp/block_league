local function can_use() end
local function dash() end



local function register_bouncer(name, desc, energy)

  minetest.register_tool("block_league:" .. name, {
    description = desc,
    wield_scale = {x=1.3, y=1.3, z=1.3},
    inventory_image = "bl_" .. name .. ".png",
    jump_height = 5,
    groups = {oddly_breakable_by_hand = "2"},
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      if not can_use(user) then return end

      -- se non sta puntando un nodo, annullo
      if pointed_thing.type ~= "node" then return end

      local p_name = user:get_player_name()
      local arena = arena_lib.get_arena_by_player(p_name)

      if arena then
        -- se non ha abbastanza energia, annullo
        if not (arena.players[p_name].energy >= energy) then return end
        arena.players[p_name].energy = arena.players[p_name].energy - energy
      end

      local dir = user:get_look_dir()
      local knockback = user:get_velocity().y < 1 and -15 or -10

      user:add_velocity(vector.multiply(dir, knockback))
      block_league.sound_play("bl_bouncer", p_name)
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
      dash(user, energy)
    end,

    on_place = function(itemstack, user, pointed_thing)
      dash(user, energy)
    end
  })
end



register_bouncer("bouncer", "Bouncer", 20)
register_bouncer("bouncer_dm", "Deathmatch Bouncer", 50)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function dash(player, energy)
  if not can_use(player) then return end

  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)

  if arena then
    -- se non ha abbastanza energia, annullo
    if not (arena.players[p_name].energy >= energy) then return end
    arena.players[p_name].energy = arena.players[p_name].energy - energy
  end

  local dir = player:get_look_dir()
  local look_horizontal = player:get_look_horizontal()
  local rotate_factor = player:get_player_control().left and 1.57 or -1.57
  local dash_dir = vector.rotate_around_axis(minetest.yaw_to_dir(look_horizontal), {x=0,y=1,z=0}, rotate_factor)

  player:add_velocity(vector.multiply(dash_dir, 20))
  block_league.sound_play("bl_sword_dash", p_name)
end



function can_use(player, energy)
  local meta = player:get_meta()
  if meta:get_int("bl_bouncer_delay") == 1 or
     meta:get_int("bl_death_delay") == 1 or
     meta:get_int("bl_reloading") == 1 or
     meta:get_int("bl_is_speed_locked") == 1 then return end

  meta:set_int("bl_bouncer_delay", 1)

  minetest.after(0.3, function()
    if not player then return end
    player:get_meta():set_int("bl_bouncer_delay", 0)
  end)

  return true
end
