
function block_league.info_panel_create(arena, p_name)

    Panel:new("bl_info_panel", {
      player = p_name,
      bg_scale = { x = 45, y = 28 },
      position = { x = 0.5, y = 0.5 },
      alignment = { x = 0, y = 0 },
      title_offset = { x = 0, y = -150},
      title_color = 0xdff6f5,

      visible = false,

      sub_img_elems = {
        player_indicator = {
          scale = {x = 44, y = 1.7},
          offset = {x = 0, y = -121},
          alignment = { x = 0, y = 0 },
          text = "bl_hud_panel_playerindicator_teams.png"
        },
        team_indicator_orange = {
          scale = {x = 44, y = 1.7},
          offset = {x = 0, y = -121},
          alignment = { x = 0, y = 0 },
          text = "bl_hud_panel_teamindicator_orange.png"
        },
        team_indicator_blue = {
          scale = {x = 44, y = 1.7},
          offset = {x = 0, y = (#arena.players * 36) + (-121) + 98},
          alignment = { x = 0, y = 0 },
          text = "bl_hud_panel_teamindicator_blue.png"
        },
      },

      sub_txt_elems = {
        players_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = -250, y = -130},
          text = ""
        },
        pts_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = 0, y = -130},
          text = ""
        },
        dts_clmn = {
          alignment = { x = 0, y = 1 },
          offset = {x = 250, y = -130},
          text = ""
        },
      }
    })
end



function block_league.info_panel_update(arena)

  local plyrs_clmn = ""
  local pts_clmn = ""
  local third_clmn = ""

  -- creo una tabella per avere i giocatori ordinati con nome come KEY
  local players_idx = {}
  local bar_orange = -121
  local bar_blue = -121

  local bar_pos = -121             -- posizione Y più alta della barra per evidenziare il giocatore client
  local dist_between_bars = 36     -- distanza Y tra un giocatore e l'altro (equivalente a "\n\n")

  local sorted_teams = {}

  -- ordino i team
  for id, team in pairs(arena.teams) do
    --salvo anche l'id del team così da non dover iterare di nuovo
    table.insert(sorted_teams, {name = team.name, id = id})
  end

  local third_clmn_title
  local third_clmn_value

  if arena.mode == 1 then
    third_clmn_title = S("TDs")
    third_clmn_value = "TDs"
  else
    third_clmn_title = S("Deaths")
    third_clmn_value = "deaths"
  end

  -- determino come stampare i team seguiti dai giocatori
  for _, team in pairs(sorted_teams) do
    plyrs_clmn = plyrs_clmn .. S("Team") .. " " .. team.name .. "\n\n"
    pts_clmn = pts_clmn .. S("Points") .. "\n\n"
    third_clmn = third_clmn .. third_clmn_title .. "\n\n"

    if team.name == S("orange") then
      bar_orange = bar_pos
    elseif team.name == S("blue") then
      bar_blue = bar_pos
    end
    bar_pos = bar_pos + dist_between_bars

    local sorted_players = {}

    for _, pl_name in pairs(arena_lib.get_players_in_team(arena, team.id)) do
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

    plyrs_clmn = plyrs_clmn .. "\n\n"
    pts_clmn = pts_clmn .. "\n\n"
    third_clmn = third_clmn .. "\n\n"
    bar_pos = bar_pos + dist_between_bars

  end

  -- aggiorno il pannello
  for pl_name, stats in pairs(arena.players) do
    local panel = panel_lib.get_panel(pl_name, "bl_info_panel")
    local bar_height = players_idx[pl_name]    -- l'altezza della barra che segnala al client dove si trova nel panello

    panel:update(nil,

    {players_clmn = {
      text = plyrs_clmn
    },
    pts_clmn = {
      text = pts_clmn
    },
    dts_clmn = {
      text = third_clmn
    }},

    {player_indicator = {
      offset = { x = 0, y = bar_height }
    },
    team_indicator_orange = {
      offset = { x = 0, y = bar_orange }
    },
    team_indicator_blue = {
      offset = { x = 0, y = bar_blue }
    },
  })

  end
end
