-- EXP is disabled right now as we haven't decided yet what purpose should have,
-- aside as a barrier for future ranked games

local XP_MAX = 5000



function block_league.calculate_and_add_xp(p_name, entering_time, points)

  local minutes = entering_time / 60
  local xp = points > 4 and math.floor((points * 9.375) + (minutes * 12.5)) or 0

  block_league.add_xp(p_name, xp)
end



function block_league.add_xp(p_name, xp)

  local p_xp = 0 --block_league.players[p_name].XP

  if p_xp == XP_MAX then
    --minetest.chat_send_player(p_name, "Hai raggiunto il livello massimo")
    return end

  local tot_xp = math.min(p_xp + xp, XP_MAX)

  minetest.chat_send_player(p_name, minetest.colorize("#28ccdf", "[Block League] +" .. xp .. " " .. S("pass points")))
  --block_league.players[p_name].XP = tot_xp
end



function block_league.set_xp(p_name, xp)

  if xp < 0 or xp > XP_MAX then
    return false, "Qualche parametro non è corretto"
  end

  minetest.chat_send_player(p_name, "La tua exp è ora " .. xp)
  --block_league.players[p_name].XP = xp
  block_league.update_storage(p_name)
end
