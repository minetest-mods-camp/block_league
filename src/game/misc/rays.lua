local function register_rays(name, texture)
  minetest.register_node("block_league:" .. name, {
    description = "Rays",
    inventory_image = texture,
    tiles = {{
      name = texture,
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
      }}
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
      type = "fixed",
      fixed = {
        {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}
      }
    },
    light_source = 10,
    walkable = false,
    pointable = false,
    groups = {oddly_breakable_by_hand = 3}
  })
end

register_rays("rays_orange", "bl_rays_orange.png")
register_rays("rays_blue", "bl_rays_blue.png")



minetest.register_globalstep(function(dtime)
  for _, pl_name in pairs(arena_lib.get_players_in_minigame("block_league")) do
    if not arena_lib.is_player_spectating(pl_name) then
      local player = minetest.get_player_by_name(pl_name)
      local p_nodename = minetest.get_node(player:get_pos()).name
      local arena = arena_lib.get_arena_by_player(pl_name)

      if p_nodename == "block_league:rays_blue" or p_nodename == "block_league:rays_orange" then
        local p_data = arena.players[pl_name]
        local p_team = p_data.teamID

        if player:get_meta():get_int("bl_has_ball") == 1 then
          block_league.get_ball(player):reset()  -- TODO non parla di reset ma di palla persa, sistema
        end

        if player:get_hp() > 0 and ((p_team == 1 and p_nodename == "block_league:rays_blue") or (p_team == 2 and p_nodename == "block_league:rays_orange")) then
          player:set_hp(0)
          block_league.hitter_or_suicide(arena, player, p_data.dmg_received, "bl_log_rays.png")
        end
      end
    end
  end
end)