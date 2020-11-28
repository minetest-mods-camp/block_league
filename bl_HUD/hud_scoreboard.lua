function block_league.scoreboard_create(arena, p_name)

  local timer = arena.in_loading and arena.initial_time or arena.current_time

  Panel:new("bl_scoreboard", {
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



function block_league.scoreboard_update_score(arena)

  for pl_name, stats in pairs(arena.players) do

    local panel = panel_lib.get_panel(pl_name, "bl_scoreboard")
    local score_red = 0
    local score_blue = 0

    if arena.mode == 1 then
      score_red = arena.teams[1].TDs
      score_blue =  arena.teams[2].TDs
    else
      score_red = arena.teams[1].kills
      score_blue = arena.teams[2].kills
    end

    panel:update(nil, {
      team_red_score = {
        text = score_red
      },
      team_blue_score = {
        text = score_blue
      }
    })

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
