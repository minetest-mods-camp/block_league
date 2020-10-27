-- debug se devo mostrare una posizione
function block_league.mostra_posizione(pos, tempo)
  minetest.add_particlespawner({
    amount = 80,
    time = .1,
    minpos = {x=pos.x,y=pos.y,z=pos.z},
    maxpos = {x=pos.x,y=pos.y,z=pos.z},
    minvel = {x=0, y=0, z=0},
    maxvel = {x=0, y=0, z=0},
    minacc = {x=0, y=-0, z=0},
    maxacc = {x=0, y=-0, z=0},
    minexptime = tempo,
    maxexptime = tempo,
    minsize = 2,
    maxsize = 2,
    collisiondetection = false,
    vertical = false,
    texture = "block_league_rocket_particle.png",
  })

end
