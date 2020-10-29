local saved_huds = {} -- p_name = {indexes}



function block_league.broadcast_create(p_name)

  local HUD = {
    hud_elem_type = "text",
    position  = {x = 0.5, y = 0.35},
    alignment = { x = 0, y = 0},
    text      = "",
    size      = { x = 2 },
    number    = "0xFFFFFF"
  }

  local player = minetest.get_player_by_name(p_name)
  local HUD_ID = player:hud_add(HUD)

  saved_huds[p_name] = HUD_ID

end



function block_league.HUD_broadcast_remove(p_name)

  minetest.get_player_by_name(p_name):hud_remove(saved_huds[p_name])
  saved_huds[p_name] = nil
end



function block_league.HUD_broadcast_player(p_name, msg, duration, hex_color)

  local HUD_ID = saved_huds[p_name]
  local player = minetest.get_player_by_name(p_name)
  local hex_color = hex_color == nil and "0xFFFFFF" or hex_color

  player:hud_change(HUD_ID, "text", msg)
  player:hud_change(HUD_ID, "number", hex_color)

  minetest.after(duration, function()

    if not minetest.get_player_by_name(p_name) then return end    -- potrebbe essersi disconnesso
    if not player:hud_get(HUD_ID) then return end                 -- potrebbe essere uscito dalla partita (che rimuove la HUD)

    local current_message = player:hud_get(HUD_ID).text
    if msg == current_message then
      player:hud_change(HUD_ID, "text", "")
    end
  end)
end
