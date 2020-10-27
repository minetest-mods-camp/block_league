local S = minetest.get_translator("block_league")

local function cast_entity_ray() end
local function check_for_touchdown() end
local function add_point() end
local function announce_ball_possession_change() end


-- entità
local ball = {
  initial_properties = {
    physical = true,
    collide_with_objects = true,
    visual = "cube",
    visual_size = {x = 1.0, y = 1.0, z = 1.0},
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},

    textures = {
      "block_league_bullet_rocket.png",
      "block_league_bullet_rocket.png",
      "block_league_bullet_rocket.png",
      "block_league_bullet_rocket.png",
      "block_league_bullet_rocket.png",
      "block_league_bullet_rocket.png",
    },
    timer_limit = 10,
  },

  wielder = nil,
  team_name = nil,
  timer_bool = false,
  timer = 0,
  has_scored = false
}



-- eseguito quando l'entità viene distrutta
function ball:_destroy()
  self.object:remove()
  return
end



function ball:get_staticdata()
  if self == nil or self.arena == nil then return end
  return self.wielder
end



function ball:on_activate(staticdata, d_time)
  if staticdata ~= nil then

    local id, arena = arena_lib.get_arena_by_name("block_league", staticdata)

    if arena == nil or not arena.in_game then
      self:_destroy()
      return
    end

    self.wielder = nil
    self.team_name = nil
    self.timer_bool = false
    self.timer = 0
    self.arena = arena

    local velocity = self.object:get_velocity()

    velocity.y = velocity.y + 1
    cast_entity_ray(self.object)

    self.object:set_velocity(velocity)
    minetest.after(1, function()
      if self.object ~= nil then
        velocity = self.object:get_velocity()
        if velocity ~= nil then
          velocity.y = -velocity.y
          self.object:set_velocity(velocity)
        end
      end
    end)

  else --se gli staticdata sono nil
    self:_destroy()
    return
  end

end



function ball:on_step(d_time, moveresult)
  local id, arena = arena_lib.get_arena_by_name("block_league", self.arena.name)

  if not arena or not arena.in_game then
    self:_destroy()
    return
  end

  --se nessuno la sta portando a spasso...
  if self.wielder == nil then

    -- se il timer per il reset è attivo, controllo a che punto sta
    if self.timer_bool then
      self.timer = self.timer + d_time
      if self.timer > self.initial_properties.timer_limit then
        self:reset()
        return
      end
    end

    local pos = self.object:get_pos()
    local objects = minetest.get_objects_inside_radius(pos, 1.5)

    -- se nel suo raggio trova un giocatore in vita, si attacca
    for i, object in pairs(objects) do
      if object:is_player() and object:get_hp() > 0 then

        self:attach(object)
        return

      end
    end

    local velocity = self.object:get_velocity()

    -- sennò oscilla
    for index, table in pairs(moveresult.collisions) do
      if table.type == "node" and table.axis == "y" then
        velocity.y = -table.old_velocity.y
        self.object:set_velocity(velocity)
        minetest.after(1, function()
          if self.object ~= nil then
            velocity = self.object:get_velocity()
            if velocity ~= nil then
              velocity.y = -velocity.y
              self.object:set_velocity(velocity)
            end
          end
        end)
        break
      end
    end


  -- se ce l'ha qualcuno
  else

    local wielder = self.wielder
    local w_name = wielder:get_player_name()

    -- se il giocatore è morto, si sgancia e torna a oscillare
    if wielder:get_hp() <= 0 then
      if wielder:get_pos().y < arena.min_y then
        self:reset()
      return end
      self:detach()

      local velocity = self.object:get_velocity()

      velocity.y = velocity.y + 1
      self.object:set_velocity(velocity)
      minetest.after(1, function()
        if self.object ~= nil then
          velocity = self.object:get_velocity()
          if velocity ~= nil then
            velocity.y = -velocity.y
            self.object:set_velocity(velocity)
          end
        end
      end)

      return
    end

    local w_pos = wielder:get_pos()

    -- se il giocatore è vivo
    if w_pos == nil then return end

    local goal = self.team_name == S("red") and arena.destinazione_red or arena.destinazione_blue

    check_for_touchdown(id, arena, self, wielder, w_pos, goal)
  end
end



function ball:attach(player)

  local arena = self.arena
  local p_name = player:get_player_name()

  announce_ball_possession_change(arena, p_name)

  player:get_meta():set_int("blockleague_has_ball", 1)
  block_league.energy_drain(arena, p_name)

  self.object:set_attach(player, "Head", {x=0, y=5.5, z=0}, {x=0, y=0, z=0})
  self.wielder = player

  local teamID = arena.players[p_name].teamID

  self.team_name = arena.teams[teamID].name
  self.timer_bool = false
  self.timer = 0
end



function ball:detach()

  local player = self.wielder

  announce_ball_possession_change(self.arena, player:get_player_name(), true)

  player:get_meta():set_int("blockleague_has_ball", 0)
  player:set_physics_override({
            speed = 0,
            jump = 0
  })

  self.object:set_detach()
  self.wielder = nil
  self.timer_bool = true
  self.timer = 0

end



function ball:reset()

  local arena = self.arena

  -- annuncio
  for pl_name, _ in pairs(arena.players) do
    minetest.sound_play("blockleague_ball_reset", {to_player = pl_name})
    block_league.HUD_broadcast_player(pl_name, "Ball reset", 3)
  end

  if ball.wielder then
    ball.wielder:set_physics_override({
              speed = arena.high_speed,
              jump = 1.5
    })
  end

  self:_destroy()
  minetest.add_entity(arena.prototipo_spawn,"block_league:prototipo",arena.name)
  return
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function cast_entity_ray(ent)
  minetest.add_particlespawner({
    attached = ent, -- If defined, particle positions, velocities and accelerations are relative to this object's position and yaw
    amount = 10,
    time = 0,
    minpos = {x=0, y=1, z=0},
    maxpos = {x=0, y=1, z=0},
    minvel = vector.multiply({x= 0, y = 1, z = 0}, 30),
    maxvel = vector.multiply({x= 0, y = 1, z = 0}, 30),
    minsize = 20,
    maxsize = 20,
    vertical = true,
    texture = "block_league_raggio_palla.png"
  })
end



function check_for_touchdown(id, arena, ball, wielder, w_pos, goal)

  if
  math.abs(w_pos.x - goal.x) <= 1.5 and
  math.abs(w_pos.z - goal.z) <= 1.5 and
  w_pos.y >= goal.y - 1 and
  w_pos.y <= goal.y + 3 then

    add_point(wielder:get_player_name(), arena)

    wielder:set_physics_override({
              speed = arena.high_speed,
              jump = 1.5
    })
    wielder:get_meta():set_int("blockleague_has_ball", 0)

    local arena = arena
    arena.weapons_disabled = true
    minetest.after(5, function()
      teleport_players(arena)
      local pos1 = {x = arena.prototipo_spawn.x - 1, y = arena.prototipo_spawn.y - 1, z = arena.prototipo_spawn.z - 1}
      local pos2 = {x = arena.prototipo_spawn.x + 1, y = arena.prototipo_spawn.y + 1, z = arena.prototipo_spawn.z + 1}
      --minetest.load_area(pos1, pos2)
      minetest.forceload_block(pos1, pos2)
      --minetest.emerge_area(pos1, pos2)
      minetest.add_entity(arena.prototipo_spawn,"block_league:prototipo",arena.name)
      arena.weapons_disabled = false
    end)

    ball:_destroy()
  end

end

function teleport_players(arena)
  for id, team in pairs(arena.teams) do
    local players = arena_lib.get_players_in_team(arena, id, true)
    for index, player in pairs(players) do
      player:set_hp(20)
      local p_name = player:get_player_name()
      arena.players[p_name].energy = 100
      player:get_meta():set_int("reloading", 0)
      panel_lib.get_panel(p_name, "bullets_hud"):remove()
      arena.players[p_name].weapons_reload = {}
      block_league.weapons_hud_create(p_name)
      panel_lib.get_panel(p_name, "bullets_hud"):show()
      block_league.energy_update(arena, p_name)
      player:set_pos(arena_lib.get_random_spawner(arena, id))
    end
  end
end


function add_point(w_name, arena)

  local teamID = arena.players[w_name].teamID
  local enemy_teamID = teamID == 1 and 2 or 1
  local team = arena_lib.get_players_in_team(arena, teamID)
  local enemy_team = arena_lib.get_players_in_team(arena, enemy_teamID)

  for _, pl_name in pairs(team) do
    minetest.sound_play("block_league_crowd_cheer", {to_player = pl_name})
    block_league.HUD_broadcast_player(pl_name, "NICE POINT!", 3, "0x43e6FF")
  end

  for _, pl_name in pairs(enemy_team) do
    minetest.sound_play("block_league_crowd_ohno", {to_player = pl_name})
    block_league.HUD_broadcast_player(pl_name, "ENEMY TEAM SCORED...", 3, "0xFF5D43")
  end

  arena.teams[teamID].TDs = arena.teams[teamID].TDs + 1

  for pl_name, stats in pairs(arena.players) do
    block_league.HUD_teams_score_update(arena, pl_name, teamID)
  end

  -- se i TD della squadra raggiungono il cap, vince
  if arena.teams[teamID].TDs == arena.score_cap then
    arena_lib.load_celebration("block_league", arena, {w_name})
  end

end



function announce_ball_possession_change(arena, w_name, is_ball_lost)

  local teamID = arena.players[w_name].teamID
  local enemy_teamID = teamID == 1 and 2 or 1
  local team = arena_lib.get_players_in_team(arena, teamID)
  local enemy_team = arena_lib.get_players_in_team(arena, enemy_teamID)

  if is_ball_lost then
    for _, pl_name in pairs(team) do
      minetest.sound_play("block_league_crowd_ohno", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, "Your team lost the ball!", 3, "0xFF5D43")
    end

    for _, pl_name in pairs(enemy_team) do
      minetest.sound_play("block_league_crowd_cheer", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, "Enemy team lost the ball!", 3, "0x43e6FF")
    end
  else
    for _, pl_name in pairs(team) do
      minetest.sound_play("block_league_crowd_cheer", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, "Your team got the ball!", 3, "0x43e6FF")
    end
    block_league.HUD_broadcast_player(w_name, "You got the ball!", 3, "0x43e6FF")

    for _, pl_name in pairs(enemy_team) do
      minetest.sound_play("block_league_crowd_ohno", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, "Enemy team got the ball!", 3, "0xFF5D43")
    end
  end
end





minetest.register_entity("block_league:prototipo", ball)
