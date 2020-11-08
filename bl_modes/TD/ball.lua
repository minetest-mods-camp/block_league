local S = minetest.get_translator("block_league")

local function cast_entity_ray() end
local function announce_ball_possession_change() end
local function check_for_touchdown() end
local function add_point() end
local function after_point() end


-- entità
local ball = {
  initial_properties = {
    physical = true,
    collide_with_objects = false,
    visual = "cube",
    visual_size = {x = 1.0, y = 1.0, z = 1.0},
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},

    textures = {
      "bl_bullet_rocket.png",
      "bl_bullet_rocket.png",
      "bl_bullet_rocket.png",
      "bl_bullet_rocket.png",
      "bl_bullet_rocket.png",
      "bl_bullet_rocket.png",
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

    cast_entity_ray(self.object)

    self:oscillate()

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
      return end
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
      self:oscillate()

      return
    end

    local w_pos = wielder:get_pos()

    -- se il giocatore è vivo
    if w_pos == nil then return end

    local goal = self.team_name == S("red") and arena.goal_red or arena.goal_blue

    check_for_touchdown(id, arena, self, wielder, w_pos, goal)
  end
end



function ball:attach(player)

  local arena = self.arena
  local p_name = player:get_player_name()

  announce_ball_possession_change(arena, p_name)

  player:get_meta():set_int("bl_has_ball", 1)
  block_league.energy_drain(arena, p_name)

  self.object:set_attach(player, "Head", {x=0, y=10.5, z=0}, {x=0, y=0, z=0})
  self.wielder = player

  local teamID = arena.players[p_name].teamID

  self.team_name = arena.teams[teamID].name
  self.timer_bool = false
  self.timer = 0
end



function ball:detach()

  local player = self.wielder

  announce_ball_possession_change(self.arena, player:get_player_name(), true)

  player:get_meta():set_int("bl_has_ball", 0)
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
    minetest.sound_play("bl_voice_ball_reset", {to_player = pl_name})
    block_league.HUD_broadcast_player(pl_name, S("Ball reset"), 3)
  end
  --if the player dies because of falling in the void wielder is nil
  if self.wielder then
    self:detach()
  end
  self.wielder = nil
  self.team_name = nil
  self.timer_bool = false
  self.timer = 0
  self.object:set_pos(arena.ball_spawn)
  --if the ball is not moving up or down then start the movement
  if self.object:get_velocity().y == 0 then
    self:oscillate()
  end

end


function ball:oscillate()

  local velocity = self.object:get_velocity()

  velocity.y = velocity.y + 1
  self.object:set_velocity(velocity)

  minetest.after(1, function()
    if not self.object then return end
    velocity = self.object:get_velocity()
    if not velocity then return end
    velocity.y = -velocity.y
    self.object:set_velocity(velocity)
  end)
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
    texture = "bl_ball_ray.png"
  })
end



function check_for_touchdown(id, arena, ball, wielder, w_pos, goal)

  if
  math.abs(w_pos.x - goal.x) <= 1.5 and
  math.abs(w_pos.z - goal.z) <= 1.5 and
  w_pos.y >= goal.y - 1 and
  w_pos.y <= goal.y + 3 then

    wielder:get_meta():set_int("bl_has_ball", 0)

    local w_name = wielder:get_player_name()
    local teamID = arena.players[w_name].teamID

    add_point(teamID, arena)
    after_point(w_name, teamID, arena)

    ball:_destroy()
  end

end



function add_point(teamID, arena)

  local enemy_teamID = teamID == 1 and 2 or 1
  local team = arena_lib.get_players_in_team(arena, teamID)
  local enemy_team = arena_lib.get_players_in_team(arena, enemy_teamID)

  for _, pl_name in pairs(team) do
    minetest.sound_play("bl_crowd_cheer", {to_player = pl_name})
    block_league.HUD_broadcast_player(pl_name, S("NICE POINT!"), 3, "0x43e6FF")
  end

  for _, pl_name in pairs(enemy_team) do
    minetest.sound_play("bl_crowd_ohno", {to_player = pl_name})
    block_league.HUD_broadcast_player(pl_name, S("ENEMY TEAM SCORED..."), 3, "0xFF5D43")
  end

  arena.teams[teamID].TDs = arena.teams[teamID].TDs + 1
  block_league.scoreboard_update_score(arena)
end



function after_point(w_name, teamID, arena)

  arena.weapons_disabled = true

  -- se rimane troppo poco tempo, aspetta la fine del match
  if arena.current_time <= 6 then return end

  -- se i TD della squadra raggiungono il cap, vince
  if arena.teams[teamID].TDs == arena.score_cap then
    arena_lib.load_celebration("block_league", arena, {w_name})

  -- sennò inizia un nuovo round
  else
    minetest.after(2, function()
      for pl_name, _ in pairs(arena.players) do
        minetest.sound_play("bl_voice_countdown", {to_player = pl_name})
      end
    end)

    minetest.after(5, function()
      block_league.round_start(arena)
    end)
  end
end



function announce_ball_possession_change(arena, w_name, is_ball_lost)

  local teamID = arena.players[w_name].teamID
  local enemy_teamID = teamID == 1 and 2 or 1
  local team = arena_lib.get_players_in_team(arena, teamID)
  local enemy_team = arena_lib.get_players_in_team(arena, enemy_teamID)

  if is_ball_lost then
    for _, pl_name in pairs(team) do
      minetest.sound_play("bl_crowd_ohno", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, S("Your team lost the ball!"), 3, "0xFF5D43")
    end

    for _, pl_name in pairs(enemy_team) do
      minetest.sound_play("bl_crowd_cheer", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, S("Enemy team lost the ball!"), 3, "0x43e6FF")
    end
  else
    for _, pl_name in pairs(team) do
      minetest.sound_play("bl_crowd_cheer", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, S("Your team got the ball!"), 3, "0x43e6FF")
    end
    block_league.HUD_broadcast_player(w_name, S("You got the ball!"), 3, "0x43e6FF")

    for _, pl_name in pairs(enemy_team) do
      minetest.sound_play("bl_crowd_ohno", {to_player = pl_name})
      block_league.HUD_broadcast_player(pl_name, S("Enemy team got the ball!"), 3, "0xFF5D43")
    end
  end
end





minetest.register_entity("block_league:ball", ball)
