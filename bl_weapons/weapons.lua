local function get_dist() end
local function draw_particles() end
local function weapon_left_click() end
local function weapon_right_click() end
local function weapon_reload() end
local function can_shoot() end
local function check_immunity() end
local function update_magazine() end
local function shoot_generic() end
local function after_damage() end
local function kill() end

function block_league.register_weapon(name, def)

  -- usato per avere una dichiarazione pulita E al tempo stesso non dover
  -- passare anche il nome in on_use (che lo richiede)
  def.name = name

  minetest.register_node(name, {
    name = def.name,

    description = def.description,
    drawtype = def.mesh and "mesh" or "item",
    mesh = def.mesh or nil,
    tiles = def.tiles or nil,
    wield_image = def.wield_image or nil,
    wield_scale = def.wield_scale,
    inventory_image = def.inventory_image,

    type = def.type,

    damage = def.damage,
    knockback = def.knockback,
    weap_delay = def.weap_delay,

    pierce = def.pierce,
    decrease_damage_with_distance = def.decrease_damage_with_distance,
    slow_down_when_firing = def.slow_down_when_firing,
    continuos_fire = def.continuos_fire,

    sound_shoot = def.sound_shoot,
    bullet_trail = def.bullet_trail,

    consume_bullets = def.consume_bullets,
    magazine = def.magazine,
    reload_time = def.reload_time,

    bullet = def.bullet and block_league.register_bullet(def.bullet, def.damage, def.bullet_trail) or nil,

    -- LMB = first fire
    on_use = function(itemstack, user, pointed_thing)
      weapon_left_click(def, user, pointed_thing)
    end,

    -- RMB = secondary use
    on_secondary_use = function(itemstack, user, pointed_thing)
      weapon_right_click(def, user, pointed_thing)
    end,

    on_place = function(itemstack, user, pointed_thing)
      weapon_right_click(def, user, pointed_thing)
    end,

    -- Q = reload
    on_drop = function(itemstack, user, pointed_thing)
      weapon_reload(def, user, name)
    end

  })

end



function block_league.shoot_hitscan(user, weapon, itemstack, pointed_thing)
  local dir = user:get_look_dir()
  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
  local pointed_players = block_league.get_pointed_players(pos_head, dir, weapon.range, user, weapon.bullet_trail, weapon.pierce)

  if pointed_players then
    block_league.apply_damage(user, pointed_players, weapon.damage, weapon.knockback, weapon.decrease_damage_with_distance)
  end
end



function block_league.shoot_bullet(user, bullet, itemstack, pointed_thing)

  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y + user:get_properties().eye_height, z = pos.z}
  local bullet_name = bullet.name .. '_entity'

  local bullet = minetest.add_entity(pos_head, bullet_name, user:get_player_name())

  local speed = bullet.speed
  local dir = user:get_look_dir()

  bullet:set_velocity({
    x=(dir.x * speed),
    y=(dir.y * speed),
    z=(dir.z * speed),
  })

  local yaw = user:get_look_horizontal()
  local pitch = user:get_look_vertical()
  local rotation = ({x = -pitch, y = yaw, z = 0})

  bullet:set_rotation(rotation)
end



-- ritorna un array di giocatori con il numero di giocatori trovati a indice 1.
-- Se non trova giocatori diversi da se stesso ritorna nil
function block_league.get_pointed_players(head_pos, dir, range, user, particle, has_piercing)

	local p1 = vector.add(head_pos, vector.multiply(dir, 0))
	local p2 = vector.add(head_pos, vector.multiply(dir, range))

	local ray = minetest.raycast(p1, p2, true, false)
	local players = {}

  -- check su ogni cosa attraversata dal raycast (p1 a p2)
	for hit in ray do
    -- se è un oggetto
		if hit.type == "object" then
      -- se è un giocatore
			if hit.ref and hit.ref:is_player() then
        -- e non è colui che spara
				if hit.ref ~= user then
					table.insert(players, hit.ref)
				end
			elseif hit.ref:get_luaentity() then
        local entity = hit.ref:get_luaentity()
        if entity.initial_properties ~= nil then

          if entity.initial_properties.is_bullet or entity.initial_properties.is_grenade then
            --distrugge sia il proiettile con cui collide che se stesso
            entity.old_p_name = entity.p_name
            entity.p_name = user:get_player_name()

            entity:_destroy()
          end
        end
      end
		else
      -- se è un nodo mi fermo, e ritorno l'array se > 0 (ovvero ha trovato giocatori)
			if hit.type == "node" then
				if #players > 0 then
          if particle ~= nil and particle ~= false then
            if not has_piercing then
              local impact_dist = get_dist(head_pos, players[1]:get_pos())
              draw_particles(particle, dir, p1, range, impact_dist)
            else
              local impact_dist = get_dist(head_pos, hit.intersection_point)
              draw_particles(particle, dir, p1, range, impact_dist)
            end
          end
					return players
				else
          if particle ~= nil and particle ~= false then
            local impact_dist = get_dist(head_pos, hit.intersection_point)
          	draw_particles(particle, dir, p1, range, impact_dist)
          end
					return nil
				end
      end
		end
	end

  -- se ho sparato a qualcuno senza incrociare blocchi
  if #players > 0 then
    if particle ~= nil and particle ~= false then
      if has_piercing then
        draw_particles(particle, dir, p1, range, 120)
        return players
      else
        local impact_dist = get_dist(head_pos, players[1]:get_pos())
        draw_particles(particle, dir, p1, range, impact_dist)
        return {players[1]}
      end
    end
  else
    if particle ~= nil and particle ~= false then
      draw_particles(particle, dir, p1, range, 120)
    end
    return nil
  end
end



-- block_league.apply_damage(user, pointed_players, bullet_definition.bullet_damage, bullet_definition.knockback, bullet_definition.decrease_damage_with_distance)
-- può avere uno o più target: formato ObjectRef
function block_league.apply_damage(user, targets, damage, knockback, decrease_damage_with_distance, knockback_dir)
  local p_name = user:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)
  local killed_players = 0

  if not arena or arena.in_queue or arena.in_loading or arena.in_celebration then return end

  if type(targets) ~= "table" then
    targets = {targets}
  end

  -- per ogni giocatore colpito
  for _, target in pairs(targets) do

    if target:get_hp() <= 0 then return end

    local t_name = target:get_player_name()

    -- se player e target sono nella stessa squadra, annullo
    if arena_lib.is_player_in_same_team(arena, p_name, t_name) then return end

    -- eventuale knockback
    if knockback > 0 and knockback_dir then
      local knk= vector.multiply(knockback_dir,knockback)
      target:add_player_velocity(knk)
    end

    local remaining_HP = target:get_hp() - damage

    -- applico il danno
    target:set_hp(remaining_HP, {type = "set_hp", player_name = p_name})

    -- se è ancora vivo, riproduco suono danno
    if target:get_hp() > 0 then
      minetest.sound_play("bl_hit", {
        to_player = p_name,
        max_hear_distance = 1,
      })
    -- sennò kaputt
    else
      kill(arena, p_name, target)
      if t_name ~= p_name then
        killed_players = killed_players +1
      end
    end

  end

  -- calcoli post-danno
  after_damage(arena, p_name, killed_players)
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_dist(pos1, pos2)
  local lenx = math.abs(pos1.x - pos2.x)
  local leny = math.abs(pos1.y - pos2.y)
  local lenz = math.abs(pos1.z - pos2.z)
  local hypot = math.sqrt((lenx * lenx) + (lenz * lenz))
  local dist = math.sqrt((hypot * hypot) + (leny * leny))
  return dist
end



function draw_particles(particle, dir, origin, range, impact_dist)
  minetest.add_particlespawner({
    amount = particle.amount,
    time = 0.3,
    minpos = origin,
    maxpos = origin,
    minvel = vector.multiply(dir, range),
    maxvel = vector.multiply(dir, range),
    minexptime = impact_dist/(range * 1.5),
    maxexptime = impact_dist/(range * 1.5),
    size = 2,
    collisiondetection = false,
    vertical = false,
    texture = particle.image
  })
end



function weapon_left_click(weapon, player, pointed_thing)

  if not can_shoot(player, weapon) then return end

  check_immunity(player)
  update_magazine(player, weapon)

  local p_name = player:get_player_name()

  if weapon.sound_shoot then
    minetest.sound_play(weapon.sound_shoot, {to_player = p_name})
  end

  if weapon.slow_down_when_firing then
      player:set_physics_override({
        speed = block_league.SPEED_LOW,
        jump = 1.5
      })
  end

  shoot_generic(player, weapon, itemstack, pointed_thing)

  if weapon.continuos_fire then
    controls.register_on_hold(function(player, key, time)
      if key~="LMB" then return end

      if player:get_wielded_item():get_name() == weapon.name then

        if not can_shoot(player, weapon) then return end

        check_immunity(player)
        update_magazine(player, weapon)

        local p_name = player:get_player_name()

        if weapon.sound_shoot then
           minetest.sound_play(weapon.sound_shoot, {to_player = p_name})
         end

       shoot_generic(player, weapon, itemstack, pointed_thing)

      elseif weapon.slow_down_when_firing and player:get_meta():get_int("bl_has_ball") == 0 and arena_lib.is_player_in_arena(p_name) then
       if player then
          player:set_physics_override({
            speed = block_league.SPEED,
            jump = 1.5
          })
        end
      end
    end)

  end

  controls.register_on_release(function(player, key, time)
    if key~="LMB" then return end
      local wielditem = player:get_wielded_item()

      if wielditem:get_name() == weapon.name then

        if not weapon.slow_down_when_firing or player:get_meta():get_int("bl_has_ball") ~= 0 then return end

        minetest.after(0.1, function()
          if not player then return end
          player:set_physics_override({
            speed = block_league.SPEED,
            jump = 1.5
          })
        end)

      elseif weapon.slow_down_when_firing and player:get_meta():get_int("bl_has_ball") == 0 and arena_lib.is_player_in_arena(player:get_player_name()) then
        if player then
           player:set_physics_override({
             speed = block_league.SPEED,
             jump = 1.5
           })
         end
       end
  end)
end



function weapon_right_click(weapon, player, pointed_thing)

  if not weapon.on_right_click then return end

  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or player:get_hp() <= 0 or arena.weapons_disabled then return end

  local p_meta = player:get_meta()

  ----- gestione delay dell'arma -----
  if p_meta:get_int("bl_weap_secondary_delay") == 1 or p_meta:get_int("bl_death_delay") == 1 then
    return end

  p_meta:set_int("bl_weap_secondary_delay", 1)

  minetest.after(weapon.weap_secondary_delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weap_secondary_delay", 0)
  end)
  ----- fine gestione delay -----

  check_immunity(player)

  if weapon.on_right_click then
    weapon.on_right_click(arena, name, weapon, player, pointed_thing)
  end
end



function weapon_reload(weapon, player, name)

  local p_name = player:get_player_name()
  local p_meta = player:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or player:get_hp() <= 0
     or arena.weapons_disabled or weapon.type == 3 or not weapon.magazine
     or weapon.magazine == 0 or p_meta:get_int("bl_reloading") == 1
    then return end

  p_meta:set_int("bl_reloading", 1)

  minetest.after(weapon.reload_time, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weap_delay", 0)
    p_meta:set_int("bl_reloading", 0)

    arena.players[p_name].weapons_magazine[name] = weapon.magazine
    block_league.weapons_hud_update(arena, p_name, name, arena.players[p_name].weapons_magazine[name])
  end)

end



function can_shoot(player, weapon)

  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name) then return end

  local p_meta = player:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)
  local w_name = weapon.name

  if player:get_hp() <= 0 or arena.weapons_disabled then return end
  if weapon.magazine and weapon.magazine <= 0 then return end

  ----- gestione delay dell'arma -----
  if p_meta:get_int("bl_weap_delay") == 1 or
     p_meta:get_int("bl_death_delay") == 1 or
     p_meta:get_int("bl_reloading") == 1 then
    return false end

  p_meta:set_int("bl_weap_delay", 1)

  minetest.after(weapon.weap_delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    if weapon.magazine and p_meta:get_int("bl_reloading") == 0 then
      p_meta:set_int("bl_weap_delay", 0)
    elseif not weapon.magazine then
      p_meta:set_int("bl_weap_delay", 0)
    end
  end)
  ----- fine gestione delay -----

  --[[  Per quando si avranno caricatori limitati
  if weapon.consume_bullets then
    if inv:contains_item("main", weapon.bullet) then
      inv:remove_item("main", weapon.bullet)
      block_league.weapons_hud_update(arena, p_name, w_name)
    else
      return false
    end
  end]]

  return true
end



function check_immunity(player)
  if player:get_armor_groups().immortal and player:get_armor_groups().immortal == 1 then
    player:set_armor_groups({immortal = nil})
  end
end



function update_magazine(player, weapon)

  if not weapon.magazine or weapon.magazine <= 0 then return end

  local w_name = weapon.name
  local p_name = player:get_player_name()
  local p_meta = player:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)

  arena.players[p_name].weapons_magazine[w_name] = arena.players[p_name].weapons_magazine[w_name] - 1

  -- automatically reload if the magazine is now empty
  if arena.players[p_name].weapons_magazine[w_name] == 0 and p_meta:get_int("bl_reloading") == 0 then
    p_meta:set_int("bl_reloading", 1)

    minetest.after(weapon.reload_time, function()
      if player then
        p_meta:set_int("bl_weap_delay", 0)
        p_meta:set_int("bl_reloading", 0)
        arena.players[p_name].weapons_magazine[w_name] = weapon.magazine
        block_league.weapons_hud_update(arena, p_name, w_name, arena.players[p_name].weapons_magazine[w_name])
      end
    end)
  end

  block_league.weapons_hud_update(arena, p_name, w_name, arena.players[p_name].weapons_magazine[w_name])
end



function shoot_generic(player, weapon, itemstack, pointed_thing)

  if weapon.type ~= 3 then
      local bullet = weapon.bullet or nil

      if weapon.type == 1 then
        block_league.shoot_hitscan(player, weapon, itemstack, pointed_thing)
      elseif weapon.type == 2 then
        block_league.shoot_bullet(player, bullet, itemstack, pointed_thing)
      end

  else
      if pointed_thing.type ~= "object" or not pointed_thing.ref:is_player() then return end

      block_league.apply_damage(player, pointed_thing.ref, weapon.damage, weapon.knockback, false, player:get_look_dir())
  end
end



function after_damage(arena, p_name, killed_players)

  -- eventuale achievement doppia/tripla uccisione
  if killed_players > 1 then

    if killed_players == 2 then
      block_league.add_achievement(p_name, 1)
    elseif killed_players >= 3 then
      block_league.add_achievement(p_name, 2)
    end

    arena_lib.send_message_players_in_arena(arena, minetest.colorize("#eea160", p_name .. " ") .. minetest.colorize("#d7ded7", S("has killed @1 players in a row!", killed_players)))
  end

end



function kill(arena, p_name, target)

  -- riproduco suono morte
  minetest.sound_play("bl_kill", {to_player = p_name})

  local t_name = target:get_player_name()

  if t_name ~= p_name then

    -- informo dell'uccisione
    block_league.HUD_broadcast_player(p_name, S("YOU'VE KILLED @1", t_name), 2.5)
    minetest.chat_send_player(t_name, minetest.colorize("#d7ded7", S("You've been killed by @1", minetest.colorize("#eea160", p_name))))

    local p_stats = arena.players[p_name]
    local team = arena.teams[arena.players[p_name].teamID]

    -- aggiungo la kill
    team.kills = team.kills +1
    p_stats.kills = p_stats.kills +1

    -- aggiorno HUD
    block_league.scoreboard_update(arena)
    for pl_name, stats in pairs(arena.players) do
      block_league.teams_score_update(arena, pl_name, p_stats.teamID)
    end

    -- se è DM e il cap è raggiunto, finisce match
    if arena.mod == 2 then
      local team = arena.teams[arena.players[p_name].teamID]
      if team.kills == arena.score_cap then
        local mod = arena_lib.get_mod_by_player(p_name)
        arena_lib.load_celebration(mod, arena, {p_name})
      end
    end
  else
    block_league.HUD_broadcast_player(t_name, S("You've killed yourself"), 2.5)
  end

end
