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

  w_name = nil,
  is_going_up = nil,
  team_id = nil,
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
  return self.w_name
end



function ball:on_activate(staticdata, d_time)
  if staticdata ~= nil then

    local id, arena = arena_lib.get_arena_by_name("block_league", staticdata)

    if arena == nil or not arena.in_game then
      self:_destroy()
      return
    end

    arena_lib.add_spectable_target("block_league", arena.name, "entity", "Ball", self)

    self.w_name = nil
    self.timer_bool = false
    self.team_id = nil
    self.timer = 0
    self.arena = arena
    self.object:set_hp(65535)

    cast_entity_ray(self.object)

    self:oscillate()

  else --se gli staticdata sono nil
    self:_destroy()
    return
  end

end



function ball:on_step(d_time, moveresult)
  local arena = self.arena

  if not arena or not arena.in_game then
    self:_destroy()
    return
  end

  --se nessuno la sta portando a spasso...
  if self.w_name == nil then

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
      if object:is_player() and object:get_hp() > 0 and arena.players[object:get_player_name()] then

        self:attach(object)
        return

      end
    end

    local velocity = self.object:get_velocity()

    -- sennò oscilla
    for index, table in pairs(moveresult.collisions) do
      if table.type == "node" and table.axis == "y" then
        velocity.y = -table.old_velocity.y
        if velocity.y > 0 then
          self.is_going_up = true
        else
          self.is_going_up = false
        end
        self.object:set_velocity(velocity)
        minetest.after(1, function()
          if self.object ~= nil and self.is_going_up then
            velocity = self.object:get_velocity()
            if velocity ~= nil then
              velocity.y = -velocity.y
              if velocity.y > 0 then
                self.is_going_up = true
              else
                self.is_going_up = false
              end
              self.object:set_velocity(velocity)
            end
          end
        end)
        break
      end
    end



  -- se ce l'ha qualcuno
  -- NB: se quel qualcuno è appena morto, al posto di controllarlo qui su ogni step, viene controllato sul callback della morte in player_manager.lua
  else
    local w_name = self.w_name
    local wielder = minetest.get_player_by_name(w_name)

    -- se si è disconnesso
    if not wielder then
      self:detach()
      self:oscillate()
      return
    end

    local w_pos = wielder:get_pos()
    local goal = arena.teams[self.team_id].name == S("orange") and arena.goal_orange or arena.goal_blue

    check_for_touchdown(arena, self, w_name, w_pos, goal)
  end
end



function ball:attach(player)

  local arena = self.arena
  local p_name = player:get_player_name()

  self.w_name = p_name
  self.team_id = arena.players[p_name].teamID

  self:announce_ball_possession_change()

  player:get_meta():set_int("bl_has_ball", 1)
  block_league.energy_drain(arena, p_name)

  arena.players[p_name].points = arena.players[p_name].points + 2
  block_league.info_panel_update(arena)
  block_league.HUD_spectate_update(arena, p_name, "ball")

  self.object:set_attach(player, "Body", {x=0, y=18, z=0}, {x=0, y=0, z=0})

  self.timer_bool = false
  self.timer = 0
end



function ball:detach()

  local p_name = self.w_name
  local player = minetest.get_player_by_name(p_name)
  local arena = self.arena

  self:announce_ball_possession_change(true)

  if arena.players[p_name] then
    player:get_meta():set_int("bl_has_ball", 0)
    block_league.HUD_spectate_update(arena, p_name, "ball")
  end

  self.object:set_detach()

  self.w_name = nil
  self.timer_bool = true
  self.timer = 0

end



function ball:reset()

  local arena = self.arena

  -- annuncio
  for psp_name, _ in pairs(arena.players_and_spectators) do
    minetest.sound_play("bl_voice_ball_reset", {to_player = psp_name})
    block_league.HUD_ball_update(psp_name, S("Ball reset"))
  end

  --if the player dies because of falling in the void wielder_name is nil
  if self.w_name then
    self:detach()
  end
  self.w_name = nil
  self.team_id = nil
  self.timer_bool = false
  self.timer = 0
  self.object:set_pos(arena.ball_spawn)

  self:oscillate()

end


function ball:oscillate()

  local velocity = {x = 0, y = 1, z = 0}

  self.object:set_velocity(velocity)
  self.is_going_up = true

  minetest.after(1, function()
    if not self.object or not self.is_going_up then return end
    velocity = self.object:get_velocity()
    if not velocity then return end
    velocity.y = -velocity.y
    self.is_going_up = false
    self.object:set_velocity(velocity)
  end)
end



function ball:announce_ball_possession_change(is_ball_lost)
  local arena = self.arena
  local teamID = self.team_id
  local enemy_teamID = teamID == 1 and 2 or 1
  local team = arena_lib.get_players_in_team(arena, teamID)
  local enemy_team = arena_lib.get_players_in_team(arena, enemy_teamID)

  if is_ball_lost then
    for _, pl_name in pairs(team) do
      minetest.sound_play("bl_crowd_ohno", {to_player = pl_name})
      block_league.HUD_ball_update(pl_name, S("Your team lost the ball!"), "0xff8e8e")
    end

    for _, pl_name in pairs(enemy_team) do
      minetest.sound_play("bl_crowd_cheer", {to_player = pl_name})
      block_league.HUD_ball_update(pl_name, S("Enemy team lost the ball!"), "0xabf877")
    end

  else
    local w_name = self.w_name
    block_league.hud_log_update(arena, "bl_log_ball.png", w_name, "")

    for _, pl_name in pairs(team) do
      minetest.sound_play("bl_crowd_cheer", {to_player = pl_name})
      block_league.HUD_ball_update(pl_name, S("Your team got the ball!"), "0xabf877")
    end
    block_league.HUD_ball_update(w_name, S("You got the ball!"), "0xabf877")

    for _, pl_name in pairs(enemy_team) do
      minetest.sound_play("bl_crowd_ohno", {to_player = pl_name})
      block_league.HUD_ball_update(pl_name, S("Enemy team got the ball!"), "0xff8e8e")
    end
  end
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



function check_for_touchdown(arena, ball, w_name, w_pos, goal)

  if
  math.abs(w_pos.x - goal.x) <= 1.5 and
  math.abs(w_pos.z - goal.z) <= 1.5 and
  w_pos.y >= goal.y - 1 and
  w_pos.y <= goal.y + 3 and
  not arena.in_celebration then

    local wielder = minetest.get_player_by_name(w_name)

    wielder:get_meta():set_int("bl_has_ball", 0)

    block_league.hud_log_update(arena, "bl_log_TD.png", w_name, "")
    block_league.HUD_spectate_update(arena, w_name, "ball")

    local teamID = arena.players[w_name].teamID

    add_point(w_name, teamID, arena)
    after_point(w_name, teamID, arena)

    ball:_destroy()
  end

end



function add_point(w_name, teamID, arena)

  local enemy_teamID = teamID == 1 and 2 or 1
  local team = arena_lib.get_players_in_team(arena, teamID)
  local enemy_team = arena_lib.get_players_in_team(arena, enemy_teamID)

  for _, pl_name in pairs(team) do
    minetest.sound_play("bl_crowd_cheer", {to_player = pl_name})
    block_league.HUD_ball_update(pl_name, S("NICE POINT!"), "0xabf877")
  end

  for _, pl_name in pairs(enemy_team) do
    minetest.sound_play("bl_crowd_ohno", {to_player = pl_name})
    block_league.HUD_ball_update(pl_name, S("ENEMY TEAM SCORED..."), "0xff8e8e")
  end

  local scoring_team_color = teamID == 1 and "0xf2a05b" or "0x55aef1"

  for sp_name, _ in pairs(arena.spectators) do
    minetest.sound_play("bl_crowd_cheer", {to_player = sp_name})
    block_league.HUD_ball_update(sp_name, "TOUCHDOWN!", scoring_team_color)
  end

  arena.teams[teamID].TDs = arena.teams[teamID].TDs + 1
  arena.players[w_name].TDs = arena.players[w_name].TDs + 1
  arena.players[w_name].points = arena.players[w_name].points + 10
  block_league.scoreboard_update_score(arena)
  block_league.info_panel_update(arena)
  block_league.HUD_spectate_update(arena, w_name, "TD")
end



function after_point(w_name, teamID, arena)

  arena.weapons_disabled = true

  -- se rimane troppo poco tempo, aspetta la fine del match
  if arena.current_time <= 6 then return end

  -- se i TD della squadra raggiungono il cap, vince
  if arena.teams[teamID].TDs == arena.score_cap then
    arena_lib.load_celebration("block_league", arena, teamID)

  -- sennò inizia un nuovo round
  else
    block_league.countdown_and_start(arena, 3)
  end
end



minetest.register_entity("block_league:ball", ball)
