function block_league.scoreboard_create(p_name)

  Panel:new({
    name = "bl_scoreboard",
    player = p_name,
    position = { x = 0.5, y  = 0.018},
    alignment = { x = 0, y = 1},
    bg = "bl_hud_scoreboard.png",
    bg_scale = { x = 2.2, y = 2.2},
    title = "",

    sub_txt_elems = {
      team_red_score = {
        offset    = { x = -88, y = 41 },
        size      = { x = 2 },
        number    = "0xE6482E",
        text      = "0"
      },
      team_blue_score = {
        offset    = { x = 88, y = 41 },
        size      = { x = 2 },
        number    = "0x28CCDF",
        text      = "0"
      }
    }
  })
end

function block_league.scoreboard_update(arena, p_name, teamID)

  local panel = panel_lib.get_panel(p_name, "bl_scoreboard")
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
