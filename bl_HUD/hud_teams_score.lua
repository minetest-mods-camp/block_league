function block_league.HUD_teams_score_create(p_name)

  Panel:new({
    name = "bl_teams_score",
    player = p_name,
    position = { x = 0.5, y  = 0},
    alignment = { x = 0, y = 0},
    bg = "",
    bg_scale = { x = 15, y = 6},
    title = "",

    sub_txt_elems = {
      team_red_score = {
        offset    = { x = -50, y = 25 },
        size      = { x = 3 },
        number    = "0xFF0000",
        text      = "0"
      },
      team_blue_score = {
        offset    = { x = 50, y = 25 },
        size      = { x = 3 },
        number    = "0x00FFFF",
        text      = "0"
      }
    }
  })
end

function block_league.HUD_teams_score_update(arena, p_name, teamID)

  local panel = panel_lib.get_panel(p_name, "bl_teams_score")
  local score = 0

  if arena.mod == 1 then
    score = arena.teams[teamID].TDs
  else
    score = arena.teams[teamID].kills
  end

  if teamID == 1 then
    panel:update(nil,
    {team_red_score = {
      text = score
    }})
  else
    panel:update(nil,
    {team_blue_score = {
      text = score
    }})
  end
end
