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
