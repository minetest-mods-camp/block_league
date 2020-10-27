local function new_HUD() return end

local saved_huds = {} -- p_name = {indexes}
local show_time = {} -- p_name = time

-- la istanzio ogni volta tramite new_HUD
local HUD = {
  hud_elem_type = "image",
  position  = {x = 0.5, y = 0.25},
  offset    = {x = 0, y = 0},
  text      = "",
  scale     = { x = 4, y = 4},
  number    = 0xFFFFFF,
}



function block_league.HUD_achievements_create(p_name)

  local player = minetest.get_player_by_name(p_name)
  local basic_HUD = new_HUD(HUD)
  local slot_ID = player:hud_add(basic_HUD)

  saved_huds[p_name] = {slot_ID}
  show_time[p_name] = 0

end



function block_league.show_achievement(mod_key, p_name, achvmt_ID)

  local player = minetest.get_player_by_name(p_name)
  local last_ID = saved_huds[p_name][#saved_huds[p_name]]      -- prendo l'ultimo elemento della lista
  local last_HUD = player:hud_get(last_ID)
  local img = achievements_lib.get_achievement(mod_key, achvmt_ID).img

  -- se già sta mostrando un achievement, slitto la HUD
  if player:hud_get(last_ID).text ~= "" then

    show_time[p_name] = show_time[p_name] + 2.5

    local shift = 0.05
    local length = #saved_huds[p_name]

    -- ridichiaro perché l'ultimo indice è cambiato se un altro achievement è
    -- stato impilato
    last_HUD = player:hud_get(saved_huds[p_name][length])

    for i = 0, length-1 do
      local idx = saved_huds[p_name][length-i]
      player:hud_change(idx, "position", { x = player:hud_get(idx).position.x - shift, y = 0.25})
    end

    -- sistemo i valori del nuovo slot
    local new_HUD = new_HUD(HUD)
    new_HUD.position.x = last_HUD.position.x + shift
    new_HUD.text = img

    -- lo aggiungo
    local new_slot_ID = player:hud_add(new_HUD)

    table.insert(saved_huds[p_name], new_slot_ID)

  else
    player:hud_change(last_ID, "text", img)
  end

  -- lo uso per verificare che questo achievement sia stato l'ultimo aggiunto dopo
  -- i 2.5 secondi dell'after. Perché ogni achievement nuovo incrementa show_time
  local current_time = show_time[p_name]

  -- le immagini spariscono dopo 2.5 secondi
  minetest.after(2.5, function()

    -- se non è online, annullo
    if minetest.get_player_by_name(p_name) == nil then return end

    -- se ha ottenuto un nuovo achievement, annullo
    if current_time ~= show_time[p_name] then return end

    -- se ha più achievement a schermo, rimuovo gli slot tranne il primo
    if #saved_huds[p_name] > 1 then
      for i = 2, #saved_huds[p_name] do
        player:hud_remove(saved_huds[p_name][i])
      end
    end

    local original_ID = saved_huds[p_name][1]

    -- resetto tutto
    player:hud_change(original_ID, "text", "")
    player:hud_change(original_ID, "position", { x = 0.5, y = 0.25 })
    show_time[p_name] = 0


    saved_huds[p_name] = {original_ID}

  end)

end



function new_HUD(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[new_HUD(orig_key)] = new_HUD(orig_value)
        end
        setmetatable(copy, new_HUD(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
