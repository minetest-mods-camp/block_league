local S = minetest.get_translator("block_league")

arena_lib.on_time_tick("block_league", function(arena)
  block_league.HUD_scoreboard_update_time(arena)
end)



arena_lib.on_timeout("block_league", function(arena)

  local winner_team_ID = 0
  local team_orange = arena.teams[1]
  local team_blue = arena.teams[2]

  -- TD
  if arena.mode == 1 then
    if team_orange.TDs > team_blue.TDs then
      winner_team_ID = 1
    elseif team_blue.TDs > team_orange.TDs then
      winner_team_ID = 2
    else
      local orange_pts = 0
      local blue_pts   = 0

      for _, pl_name in pairs(arena_lib.get_players_in_team(arena, 1)) do
        orange_pts = orange_pts + arena.players[pl_name].points
      end

      for _, pl_name in pairs(arena_lib.get_players_in_team(arena, 2)) do
        blue_pts = blue_pts + arena.players[pl_name].points
      end

      if orange_pts > blue_pts then
        winner_team_ID = 1
      elseif blue_pts > orange_pts then
        winner_team_ID = 2
      end
    end

  -- DM
  else
    if team_orange.kills > team_blue.kills then
      winner_team_ID = 1
    elseif team_blue.kills > team_orange.kills then
      winner_team_ID = 2
    end
  end

  local winner_team = winner_team_ID ~= 0 and winner_team_ID or S("No one")

  arena_lib.load_celebration("block_league", arena, winner_team)
end)
