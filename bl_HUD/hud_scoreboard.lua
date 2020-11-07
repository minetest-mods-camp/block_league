function block_league.scoreboard_create(arena, p_name)

  local timer = arena.in_loading and arena.initial_time or arena.current_time

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
      },
      time = {
        offset    = { x = 0, y = 70 },
        size      = { x = 2 },
        number    = "0xDFF6F5",
        text      = os.date('!%M:%S', timer)
      },
    }
  })
end



function block_league.scoreboard_update_score(arena, p_name, teamID)

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



function block_league.scoreboard_update_time(arena)

  for pl_name, _ in pairs(arena.players) do
    local panel = panel_lib.get_panel(pl_name, "bl_scoreboard")

    panel:update(nil, {
      time = { text = os.date('!%M:%S', arena.current_time)}
    })
  end
end
