function block_league.info_panel_create(arena, p_name)

    Panel:new("bl_info_panel", {
      player = p_name,
      bg = "bl_hud_panel_bg.png",
      bg_scale = { x = 2000, y = 2000 },
      position = { x = 0.5, y = 0.5 },
      alignment = { x = 0, y = 0 },
      title_offset = { x = 0, y = -150},
      title_color = 0xdff6f5,

      visible = false,

      sub_img_elems = {
        -- TODO: indicator currently broken
        --[[player_indicator = {
          scale = {x = 30, y = 1.7},
          offset = {x = 0, y = -121},
          alignment = { x = 0, y = 0 },
          text = "bl_hud_panel_playerindicator_teams.png"
        },]]
        teams_indicator = {
          scale = {x = 2.2, y = 2.2},
          offset = {x = 0, y = -121},
          alignment = { x = 0, y = 0 },
          text = "bl_hud_panel_teamsindicator.png"
        }
      },

      sub_txt_elems = {
        y_players_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = -380, y = -130},
          text = ""
        },
        y_pts_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = -150, y = -130},
          text = ""
        },
        y_trd_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = -75, y = -130},
          text = ""
        },
        b_players_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = 100, y = -130},
          text = ""
        },
        b_pts_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = 340, y = -130},
          text = ""
        },
        b_trd_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = 415, y = -130},
          text = ""
        },
      }
    })
end



function block_league.info_panel_update_all(arena)
  block_league.info_panel_update(arena, 1)
  block_league.info_panel_update(arena, 2)
end



function block_league.info_panel_update(arena, team_id)

  local plyrs_clmn = ""
  local pts_clmn = ""
  local third_clmn = ""

  -- creo una tabella per avere i giocatori ordinati con nome come KEY
  local players_idx = {}

  local bar_pos = -121             -- posizione Y più alta della barra per evidenziare il giocatore client
  local dist_between_bars = 36     -- distanza Y tra un giocatore e l'altro (equivalente a "\n\n")

  local third_clmn_title
  local third_clmn_value

  if arena.mode == 1 then
    third_clmn_title = S("TDs")
    third_clmn_value = "TDs"
  else
    third_clmn_title = S("Deaths")
    third_clmn_value = "deaths"
  end

  -- determino come stampare le squadre seguite dai giocatori
  plyrs_clmn = plyrs_clmn .. S("Team") .. " " .. arena.teams[team_id].name .. "\n\n"
  pts_clmn = pts_clmn .. S("Points") .. "\n\n"
  third_clmn = third_clmn .. third_clmn_title .. "\n\n"

  bar_pos = bar_pos + dist_between_bars

  local sorted_players = {}

  -- ordino i giocatori
  for _, pl_name in pairs(arena_lib.get_players_in_team(arena, team_id)) do
    table.insert(sorted_players, {pl_name, arena.players[pl_name].points, arena.players[pl_name][third_clmn_value]})
  end

  table.sort(sorted_players, function (a,b) return a[2] > b[2] end)

  -- creo le stringhe dei giocatori
  for _, stats in pairs(sorted_players) do

    plyrs_clmn = plyrs_clmn .. stats[1] .. "\n\n"
    pts_clmn = pts_clmn .. stats[2] .. "\n\n"
    third_clmn = third_clmn .. stats[3] .. "\n\n"

    players_idx[stats[1]] = bar_pos
    bar_pos = bar_pos + dist_between_bars

  end

  -- aggiorno il pannello
  for pl_name, stats in pairs(arena.players) do
    local panel = panel_lib.get_panel(pl_name, "bl_info_panel")
    local x_off = stats.teamID == 1 and -280 or 280

    -- l'altezza della barra che segnala al client dove si trova nel panello
    --local bar_height = stats.teamID == team_id and players_idx[pl_name] or nil

    if team_id == 1 then

      panel:update(nil,

      {y_players_clmn = {
        text = plyrs_clmn
      },
      y_pts_clmn = {
        text = pts_clmn
      },
      y_trd_clmn = {
        text = third_clmn
      }}--[[,

      {player_indicator = {
        offset = { x = x_off, y = bar_height }
      }
    })]]
    )

    else

      panel:update(nil,

        {b_players_clmn = {
          text = plyrs_clmn
        },
        b_pts_clmn = {
          text = pts_clmn
        },
        b_trd_clmn = {
          text = third_clmn
        }}--[[,

        {player_indicator = {
          offset = { x = x_off, y = bar_height }
        }
      })]]
    )
    end
  end
end
