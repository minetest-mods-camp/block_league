-- EXP is disabled right now as we haven't decided yet what purpose should have,
-- aside as a barrier for future ranked games

function block_league.add_xp(p_name, xp)
  block_league.players[p_name].XP = block_league.players[p_name].XP + xp
end

function block_league.subtract_exp(p_name, xp)
  block_league.players[p_name].XP = block_league.players[p_name].XP - xp
  if block_league.players[p_name].XP < 0 then
    block_league.players[p_name].XP = 0
  end
end
