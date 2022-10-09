function block_league.HUD_skill_create(p_name)

  local skill, x_offset

  if arena_lib.is_player_spectating(p_name) then
    skill  = block_league.get_player_skill(arena_lib.get_player_spectated(p_name))
    x_offset = 168
  else
    skill  = block_league.get_player_skill(p_name)
    x_offset = 145
  end

  Panel:new("bl_skill", {
    player = p_name,
    bg = "bl_skill_" .. skill:sub(14, -1) .. ".png",
    position = { x = 0.5, y = 1 },
    alignment = { x = 0, y = 0 },
    offset = { x = x_offset, y = -30 },
    bg_scale = { x = 3, y = 3 },
    title = ""
  })
end



-- solo spettatori per ora
function block_league.HUD_skill_update(sp_name)
  local panel = panel_lib.get_panel(sp_name, "bl_skill")
  local skill = block_league.get_player_skill(arena_lib.get_player_spectated(sp_name))

  panel:update({bg = "bl_skill_" .. skill:sub(14, -1) .. ".png"})
end