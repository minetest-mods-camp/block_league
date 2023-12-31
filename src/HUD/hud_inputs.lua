local saved_huds = {} -- p_name = {indexes}



function block_league.HUD_show_inputs(arena)

  for pl_name, _ in pairs(arena.players) do

    local HUD = {
      hud_elem_type = "image",
      position  = {x = 0.5, y = 0.5},
      text      = "bl_hud_keyboard.png",
      scale     = { x = 4, y = 4},
      number    = "0xFFFFFF"
    }
    local player = minetest.get_player_by_name(pl_name)
    local HUD_ID = player:hud_add(HUD)

    saved_huds[pl_name] = HUD_ID
  end
end



function block_league.HUD_remove_inputs(arena_or_player_name)
  if type(arena_or_player_name) == "table" then
    for pl_name, _ in pairs(arena_or_player_name.players) do
      if saved_huds[pl_name] then
        minetest.get_player_by_name(pl_name):hud_remove(saved_huds[pl_name])
        saved_huds[pl_name] = nil
      end
    end
  else
    local p_name = arena_or_player_name
    if saved_huds[p_name] then
      minetest.get_player_by_name(p_name):hud_remove(saved_huds[p_name])
      saved_huds[p_name] = nil
    end
  end
end
