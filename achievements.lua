--
-- ATTENZIONE: questa classe funziona da magazzino per gli achievement. Se
-- invece si vuole vederne la parte grafica (come quando appaiono a schermo),
-- vedere /_HUD/hud_achievements.lua

local S = minetest.get_translator("block_league")

local achievements = {
  [1] = { name = S("two in one"),     img = "block_league_achievement_doublekill.png" },
  [2] = { name = S("three in one"),   img = "block_league_achievement_triplekill.png" }
}
local access_key = achievements_lib.register_achievements("block_league", achievements)



function block_league.add_achievement(p_name, achvmt_ID)
  achievements_lib.add_achievement(p_name, access_key, achvmt_ID)
  block_league.show_achievement(access_key, p_name, achvmt_ID)
end



function block_league.list_achievements(sender, t_name)

  local p_name = t_name or sender

  -- se il giocatore non esiste, annullo
  if not achievements_lib.is_player_in_storage(p_name, "block_league") then
    minetest.chat_send_player(sender,  minetest.colorize("#e6482e", S("[!] This player doesn't exist!")))
    return end

  local p_achievements = achievements_lib.get_player_achievements(p_name, access_key)
  local current_achievements = 0
  local achievements_to_text = "\n"

  for  i = 1, #achievements do
    if p_achievements[i] then
      achievements_to_text = achievements_to_text .. minetest.colorize("#b6d53c", "[X] " .. achievements[i].name) .. "\n"
      current_achievements = current_achievements +1
    else
      achievements_to_text = achievements_to_text .. minetest.colorize("#cfc6b8", "[ ] " .. achievements[i].name) .. "\n"
    end
  end

  minetest.chat_send_player(sender,
    minetest.colorize("#cfc6b8", "====================================") .. "\n" ..
    minetest.colorize("#eea160", S("@1 ACHIEVEMENTS", p_name) .. ": " .. current_achievements .. "/" .. #achievements) .. achievements_to_text
  )

end
