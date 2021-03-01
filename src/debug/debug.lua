local S = minetest.get_translator("block_league")

-- debug se devo mostrare una posizione
function block_league.show_position(pos, time)
  minetest.add_particlespawner({
    amount = 80,
    time = .1,
    minpos = {x=pos.x,y=pos.y,z=pos.z},
    maxpos = {x=pos.x,y=pos.y,z=pos.z},
    minvel = {x=0, y=0, z=0},
    maxvel = {x=0, y=0, z=0},
    minacc = {x=0, y=-0, z=0},
    maxacc = {x=0, y=-0, z=0},
    minexptime = time,
    maxexptime = time,
    minsize = 2,
    maxsize = 2,
    collisiondetection = false,
    vertical = false,
    texture = "bl_rocket_particle.png",
  })

end


function block_league.print_player_stats(sender, p_name)
  local pl_stats = block_league.players[p_name]

  if not pl_stats then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] This player doesn't exist!")))
    return end

  local stats = "[Block League] Player: " .. p_name .. " | Exp: " .. pl_stats.XP
  minetest.chat_send_player(sender, stats)
end
