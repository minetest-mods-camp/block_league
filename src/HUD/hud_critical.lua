local S = minetest.get_translator("block_league")
local saved_huds = {} -- p_name = {HUD_ID, display_ID}; utilizzo display_ID per controllare se il "Critical!" mostrato sia lo stesso di 1.5 secondi prima o meno



function block_league.HUD_critical_create(p_name)

  local HUD = {
    hud_elem_type = "text",
    position  = { x = 1, y = 0.5 },
    offset    = { x = -25 },
    alignment = { x = -1 },
    text      = "",
    size     = { x = 4 },
    number    = "0xe6482e"
  }
  local player = minetest.get_player_by_name(p_name)
  local HUD_ID = player:hud_add(HUD)

  saved_huds[p_name] = {HUD_ID, 0}
end



function block_league.HUD_critical_remove(p_name)
  minetest.get_player_by_name(p_name):hud_remove(saved_huds[p_name][1])
  saved_huds[p_name] = nil
end



function block_league.HUD_critical_show(p_name)
  minetest.get_player_by_name(p_name):hud_change(saved_huds[p_name][1], "text", S("CRITICAL!"))
  saved_huds[p_name][2] = saved_huds[p_name][2] + 1

  local display_ID = saved_huds[p_name][2]

  minetest.after(1.5, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end    -- se è andato offline o uscito dalla partita

    -- se nessun nuovo critico è apparso, faccio sparire
    if saved_huds[p_name][2] == display_ID then
      minetest.get_player_by_name(p_name):hud_change(saved_huds[p_name][1], "text", "")
    end
  end)
end
