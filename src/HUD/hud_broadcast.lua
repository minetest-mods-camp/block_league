local function remove_message() end

function block_league.HUD_broadcast_create(p_name)

  Panel:new("bl_broadcast", {
    player = p_name,
    position  = {x = 0.5, y = 0.33},
    bg = "",
    title = "",
    sub_txt_elems = {
      kills = {
        size    = { x = 1 },
        offset  = { x = 0, y = 30 },
        number  = "0xFFFFFF",
        text    = ""
      }
    }
  })
end



function block_league.HUD_ball_update(p_name, msg, hex_color)
  arena_lib.HUD_send_msg("title", p_name, msg, 3, _, hex_color)
end



function block_league.HUD_kill_update(p_name, msg)

  local panel = panel_lib.get_panel(p_name, "bl_broadcast")

  panel:update(nil, {
      kills = {
        text = msg
      }
  })

  remove_message(panel, "kills")
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function remove_message(panel, field)

  local old_msg = panel[field].text

  minetest.after(3, function()
    if not arena_lib.is_player_in_arena(panel.player_name, "block_league") then return end    -- se è andato offline o uscito dalla partita
                                                                                              -- usare `not panel` non funziona, non ritorna il riferimento...
    local current_message = panel[field].text
    if old_msg == current_message then
      panel:update(nil, {
          [field] = { text = "" }
      })
    end
  end)

end
