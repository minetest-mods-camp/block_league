local function create_panel() end



function block_league.HUD_spectate_create(arena, sp_name)

  local team1 = arena_lib.get_players_in_team(arena, 1)
  local team2 = arena_lib.get_players_in_team(arena, 2)
  local y_offset1 = 0.5 - ((#team1 - 1) * 0.05)
  local y_offset2 = 0.5 - ((#team2 - 1) * 0.05)

  for _, pl_name in pairs(team1) do
    create_panel(arena, sp_name, pl_name, y_offset1)
    y_offset1 = y_offset1 + 0.1
  end

  for _, pl_name in pairs(team2) do
    create_panel(arena, sp_name, pl_name, y_offset2)
    y_offset2 = y_offset2 + 0.1
  end
end



function block_league.HUD_spectate_remove(arena_players, sp_name)
  for pl_name, _ in pairs(arena_players) do
    panel_lib.get_panel(sp_name, "bl_spectate_" .. pl_name):remove()
  end
end



-- reasons = "points", "TD", "ball", "alive"
function block_league.HUD_spectate_update(arena, p_name, reason)

  if reason == "points" then
    local points = arena.players[p_name].points

    for sp_name, _ in pairs(arena.spectators) do
      local panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. p_name)

      panel:update(nil, nil, { points_amount = { text = points }})
    end

  elseif reason == "TD" then
    local points = arena.players[p_name].points
    local TDs    = arena.players[p_name].TDs

    for sp_name, _ in pairs(arena.spectators) do
      local panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. p_name)

      panel:update(nil, nil,
        {
          points_amount = { text = points },
          info2_amount    = { text = TDs }
        })
    end

  elseif reason == "ball" then
    local points = arena.players[p_name].points

    for sp_name, _ in pairs(arena.spectators) do
      local panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. p_name)
      local player = minetest.get_player_by_name(p_name)

      if player:get_meta():get_int("bl_has_ball") == 1 then
        panel:update(nil,
          {
            icon = { text = "bl_log_ball.png"}
          },
          {
            points_amount = { text = points }
          })
      else
        panel:update(nil, { icon = { text = ""}})
      end
    end

  elseif reason == "alive" then
    local is_alive = minetest.get_player_by_name(p_name):get_hp() > 0 and true or false
    local bw = "^[multiply:#555555"

    for sp_name, _ in pairs(arena.spectators) do
      local panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. p_name)
      local avatar = panel.avatar.text

      if is_alive then
        avatar = string.match(avatar, "(.*)^%[multiply")
      else
        avatar = avatar .. bw
      end

      if arena.mode == 1 then
        panel:update(nil, { avatar = { text = avatar }})
      else
        panel:update(nil,
          {
            avatar = { text = avatar }
          },
          {
            info2_amount = { text = arena.players[p_name].deaths }
          })
      end
    end
  end
end



function block_league.HUD_spectate_addplayer(arena, p_name)

  if not next(arena.spectators) then return end

  local teamID = arena.players[p_name].teamID
  local y_offset = 0.5 + ((arena.players_amount_per_team[teamID] -1) * 0.05)

  for sp_name, _ in pairs(arena.spectators) do
    -- sposto i pannelli precedenti in alto
    for _, pl_name in pairs(arena_lib.get_players_in_team(arena, teamID)) do
      if pl_name ~= p_name then
        local panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. pl_name)
        panel:update({position = {x = panel.background_def.position.x, y = panel.background_def.position.y - 0.05 }})
      end
    end

    create_panel(arena, sp_name, p_name, y_offset)
  end
end



function block_league.HUD_spectate_removeplayer(arena, p_name)

  local y, teamID

  -- ottengo altezza e squadra dal primo spettatore per non ricalcolarle ogni volta
  for sp_name, _ in pairs(arena.spectators) do
    local gone_p_panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. p_name)
    y = gone_p_panel.background_def.position.y
    teamID = gone_p_panel.spectate_bg.text == "bl_hud_spectate_bg_orange.png" and 1 or 2
    break
  end

  for sp_name, _ in pairs(arena.spectators) do
    panel_lib.get_panel(sp_name, "bl_spectate_" .. p_name):remove()

    -- riposiziono i pannelli rimasti
    for _, pl_name in pairs(arena_lib.get_players_in_team(arena, teamID)) do
      local panel = panel_lib.get_panel(sp_name, "bl_spectate_" .. pl_name)
      if panel.background_def.position.y < y then
        panel:update({ position = { x = panel.background_def.position.x, y = panel.background_def.position.y + 0.05}})
      else
        panel:update({ position = { x = panel.background_def.position.x, y = panel.background_def.position.y - 0.05}})
      end
    end
  end
end






function create_panel(arena, sp_name, p_name, y_offset)

  local name = string.len(p_name) < 13 and p_name or string.sub(p_name, 1, 12) .. "..."
  local skin = minetest.get_player_by_name(p_name):get_properties().textures[1]
  local skin_clean = string.match(skin, "(.*)^%[")
  local avatar = "([combine:24x24:0,0=" .. skin_clean .. "^[mask:bl_hud_spectate_avatarmask.png)"
  local points_amount = arena.players[p_name].points
  local info2_txt, info2_amount

  if arena.mode == 1 then
    info2_txt = "TD"
    info2_amount = arena.players[p_name].TDs
  else
    info2_txt = "D"
    info2_amount = arena.players[p_name].deaths
  end

  local teamID = arena.players[p_name].teamID

  if teamID == 1 then

    Panel:new("bl_spectate_" .. p_name, {
      player = sp_name,
      bg = "",
      position = { x = 0, y = y_offset },
      alignment = { x = 1, y = 0 },
      title_alignment = { x = 1, y = 0 },

      sub_img_elems = {
        spectate_bg = {
          scale   = { x = 2, y = 2 },
          text    = "bl_hud_spectate_bg_orange.png",
          z_index = -1
        },
        avatar = {
          scale   = { x = 6, y = 6 },
          offset  = { x = -45 },
          text    = avatar
        },
        weapon1 = {
          scale = { x = 1.4, y = 1.4 },
          offset = { x = 60, y = 10 },
          text   = "bl_smg.png"
        },
        weapon2 = {
          scale = { x = 1.4, y = 1.4 },
          offset = { x = 85, y = 10 },
          text   = "bl_sword.png"
        },
        weapon3 = {
          scale = { x = 1.4, y = 1.4 },
          offset = { x = 110, y = 10 },
          text   = "bl_pixelgun.png"
        },
        icon = {
          scale = { x = 3, y = 3 },
          offset = { x = 265 }
        }
      },

      sub_txt_elems = {
        spectate_name = {
          offset = {x = 60, y = -13 },
          text = name
        },
        points = {
          offset = {x = 215, y = -13 },
          alignment = { x = 0, y = 0 },
          text = "PT"
        },
        info2 = {
          offset = {x = 245, y = -13 },
          alignment = { x = 0, y = 0 },
          text = info2_txt
        },
        points_amount = {
          offset = {x = 215, y = 13 },
          alignment = { x = 0, y = 0 },
          text = points_amount
        },
        info2_amount = {
          offset = {x = 245, y = 13 },
          alignment = { x = 0, y = 0 },
          text = info2_amount
        },
      }
    })

  else

    Panel:new("bl_spectate_" .. p_name, {
      player = sp_name,
      bg = "",
      position = { x = 1, y = y_offset },
      alignment = { x = -1, y = 0 },
      title_alignment = { x = -1, y = 0 },

      sub_img_elems = {
        spectate_bg = {
          scale   = { x = 2, y = 2 },
          text    = "bl_hud_spectate_bg_blue.png",
          z_index = -1
        },
        avatar = {
          scale   = { x = 6, y = 6 },
          offset  = { x = 45 },
          text    = avatar
        },
        weapon1 = {
          scale = { x = 1.4, y = 1.4 },
          offset = { x = -110, y = 10 },
          text   = "bl_smg.png"
        },
        weapon2 = {
          scale = { x = 1.4, y = 1.4 },
          offset = { x = -85, y = 10 },
          text   = "bl_sword.png"
        },
        weapon3 = {
          scale = { x = 1.4, y = 1.4 },
          offset = { x = -60, y = 10 },
          text   = "bl_pixelgun.png"
        },
        icon = {
          scale = { x = 3, y = 3 },
          offset = { x = -265 }
        }
      },

      sub_txt_elems = {
        spectate_name = {
          offset = {x = -60, y = -13 },
          text = name
        },
        points = {
          offset = {x = -245, y = -13 },
          alignment = { x = 0, y = 0 },
          text = "PT"
        },
        info2 = {
          offset = {x = -215, y = -13 },
          alignment = { x = 0, y = 0 },
          text = info2_txt
        },
        points_amount = {
          offset = {x = -245, y = 13 },
          alignment = { x = 0, y = 0 },
          text = points_amount
        },
        info2_amount = {
          offset = {x = -215, y = 13 },
          alignment = { x = 0, y = 0 },
          text = info2_amount
        },
      }
    })
  end
end
