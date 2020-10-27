minetest.register_tool("block_league:bouncer", {
  description = "Bouncer",
  drawtype = "mesh",
  mesh = "block_league_pixelgun.obj",
  tiles = {"block_league_pixelgun.png"},
  wield_scale = {x=1.3, y=1.3, z=1.3},
  inventory_image = "block_league_bouncer.png",
  jump_height = 5,
  groups = {oddly_breakable_by_hand = "2"},
  on_drop = function() end,
  on_place = function() end,

  on_use = function(itemstack, user, pointed_thing)
    ----- gestione delay dell'arma -----
    if user:get_meta():get_int("blockleague_bouncer_delay") == 1 or user:get_meta():get_int("blockleague_death_delay") == 1 then return end

    user:get_meta():set_int("blockleague_bouncer_delay", 1)

    minetest.after(0.3, function()
      user:get_meta():set_int("blockleague_bouncer_delay", 0)
      end)
    ----- fine gestione delay -----

    local p_name = user:get_player_name()
    local arena = arena_lib.get_arena_by_player(p_name)

    if not arena then return end

    -- se non ha abbastanza energia o non sta puntando un nodo, annullo
    if not (arena.players[p_name].energy >= 20) or pointed_thing.type ~= "node" then return end

    local dir = user:get_look_dir()
    local knockback = user:get_player_velocity().y < 1 and -15 or -10

    user:add_player_velocity(vector.multiply(dir, knockback))
    minetest.sound_play("block_league_bouncer", {to_player = p_name, max_hear_distance = 5})

    arena.players[p_name].energy = arena.players[p_name].energy - 20
  end,
})
