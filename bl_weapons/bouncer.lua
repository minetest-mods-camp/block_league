minetest.register_tool("block_league:bouncer", {
  description = "Bouncer",
  drawtype = "mesh",
  mesh = "bl_pixelgun.obj",
  tiles = {"bl_pixelgun.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "bl_bouncer.png",
  jump_height = 5,
  groups = {oddly_breakable_by_hand = "2"},
  on_drop = function() end,
  on_place = function() end,

  on_use = function(itemstack, user, pointed_thing)
    ----- gestione delay dell'arma -----
    local meta = user:get_meta()
    if meta:get_int("bl_bouncer_delay") == 1 or
       meta:get_int("bl_death_delay") == 1 or
       meta:get_int("bl_reloading") == 1 or
       meta:get_int("bl_is_speed_locked") == 1 then return end

    user:get_meta():set_int("bl_bouncer_delay", 1)

    minetest.after(0.3, function()
      if not user then return end
      user:get_meta():set_int("bl_bouncer_delay", 0)
      end)
    ----- fine gestione delay -----

    local p_name = user:get_player_name()
    local arena = arena_lib.get_arena_by_player(p_name)

    -- se non sta puntando un nodo, annullo
    if pointed_thing.type ~= "node" then return end

    if arena then
      -- se non ha abbastanza energia, annullo
      if not (arena.players[p_name].energy >= 20) then return end
      arena.players[p_name].energy = arena.players[p_name].energy - 20
    end

    local dir = user:get_look_dir()
    local knockback = user:get_player_velocity().y < 1 and -15 or -10

    user:add_player_velocity(vector.multiply(dir, knockback))
    block_league.sound_play("bl_bouncer", p_name)

  end,
})
