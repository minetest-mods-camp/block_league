function block_league.scoreboard_create(arena, p_name, is_spectator)

  local timer = arena.in_loading and arena.initial_time or arena.current_time
  local team_marker = ""

  if not is_spectator then
    local teamID = arena.players[p_name].teamID
    team_marker = teamID == 1 and "bl_hud_scoreboard_orangemark.png" or "bl_hud_scoreboard_bluemark.png"
  end

  Panel:new("bl_scoreboard", {
    player = p_name,
    position = { x = 0.5, y  = 0.018},
    alignment = { x = 0, y = 1},
    bg = "bl_hud_scoreboard.png",
    bg_scale = { x = 2.2, y = 2.2},
    title = "",

    sub_txt_elems = {
      team_orange_score = {
        offset    = { x = -88, y = 41 },
        size      = { x = 2 },
        number    = "0xF47E1B",
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
    },

    sub_img_elems = {
      team_marker = {
        text = team_marker
      }
    }
  })
end



function block_league.scoreboard_update_score(arena)

  local score_orange = 0
  local score_blue = 0

  if arena.mode == 1 then
    score_orange = arena.teams[1].TDs
    score_blue =  arena.teams[2].TDs
  else
    score_orange = arena.teams[1].kills
    score_blue = arena.teams[2].kills
  end

  for psp_name, _ in pairs(arena.players_and_spectators) do
    local panel = panel_lib.get_panel(psp_name, "bl_scoreboard")

    panel:update(nil, {
      team_orange_score = {
        text = score_orange
      },
      team_blue_score = {
        text = score_blue
      }
    })
  end

end



function block_league.scoreboard_update_time(arena)

  for psp_name, _ in pairs(arena.players_and_spectators) do
    local panel = panel_lib.get_panel(psp_name, "bl_scoreboard")

    panel:update(nil, {
      time = { text = os.date('!%M:%S', arena.current_time)}
    })
  end

end
