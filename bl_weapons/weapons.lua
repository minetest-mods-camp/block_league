local function get_dist() end
local function draw_particles() end
local function weapon_reload() end
local function weapon_right_click() end
local function gestione_sparo() end
local function shoot_generic() end
local function after_damage() end
local function kill() end

function block_league.register_weapon(name, def)
  minetest.register_node(name, {
    name = name,
    description = def.description,
    inventory_image = def.inventory_image,
    wield_scale = def.wield_scale,

    drawtype = def.mesh and "mesh" or "item",
    mesh = def.mesh or nil,
    tiles = def.tiles or nil,
    wield_image = def.wield_image or nil,

    weap_sound_shooting = def.weap_sound_shooting or nil,
    weap_trail = def.weap_trail or nil,
    weap_damage = def.weap_damage or nil,
    consume_bullets = def.consume_bullets or nil,
    bullet = def.bullet or nil,
    magazine = def.magazine or nil,

    -- LMB = first fire
    on_use = function(itemstack, user, pointed_thing)

      local p_name = user:get_player_name()

      if not gestione_sparo(p_name, user, def, name) then return end

      if def.weap_sound_shooting then
        -- riproduzione suono
        minetest.sound_play(def.weap_sound_shooting, {
            to_player = p_name,
            max_hear_distance = 5,
        })
      end
      if def.slow_down_when_firing then
          user:set_physics_override({
              speed = block_league.SPEED_LOW,
              jump = 1.5,
              gravity = 1.15,
              sneak_glitch = true,
              new_move = true
          })
      end

      shoot_generic(def, p_name, itemstack, user, pointed_thing)

      if def.continuos_fire then
        controls.register_on_hold(function(player, key, time)
          if key~="LMB" then return end

          if player:get_wielded_item():get_name() == name then

            local p_name = player:get_player_name()

            if not gestione_sparo(p_name, player, def, name) then return end

            if def.weap_sound_shooting then
              -- riproduzione suono
               minetest.sound_play(def.weap_sound_shooting, {
                 to_player = p_name,
                 max_hear_distance = 5,
               })
           end

           shoot_generic(def, p_name, itemstack, player, pointed_thing)

         elseif def.slow_down_when_firing and player:get_meta():get_int("bl_has_ball") == 0 and arena_lib.is_player_in_arena(p_name) then
           if player then
              player:set_physics_override({
                speed = block_league.SPEED,
                jump = 1.5,
                gravity = 1.15,
                sneak_glitch = true,
                new_move = true
              })
            end
          end
        end)

      end

      controls.register_on_release(function(player, key, time)
        if key~="LMB" then return end
          local wielditem = player:get_wielded_item()
          if wielditem:get_name()==name then

            if def.slow_down_when_firing and player:get_meta():get_int("bl_has_ball") == 0 then
              minetest.after(0.1, function()
                if player then
                player:set_physics_override({
                          speed = block_league.SPEED,
                          jump = 1.5,
                          gravity = 1.15,
                          sneak_glitch = true,
                          new_move = true
                })
              end
            end)
            end
          elseif def.slow_down_when_firing and player:get_meta():get_int("bl_has_ball") == 0 and arena_lib.is_player_in_arena(player:get_player_name()) then
            if player then
               player:set_physics_override({
                         speed = block_league.SPEED,
                         jump = 1.5,
                         gravity = 1.15,
                         sneak_glitch = true,
                         new_move = true
               })
             end
           end
      end)
    end,

    -- RMB = secondary use
    on_secondary_use = function(itemstack, user, pointed_thing)
      weapon_right_click(itemstack, user, pointed_thing)
    end,

    on_place = function(itemstack, user, pointed_thing)
      weapon_right_click(itemstack, user, pointed_thing)
    end,

    -- Q = reload
    on_drop = function(itemstack, user, pointed_thing)
      weapon_reload(user, def, name)
    end

  })

end



function block_league.shoot_hitscan(name, def, bullet_definition, itemstack, user, pointed_thing)
  local dir = user:get_look_dir()
  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
  local pointed_players = block_league.get_pointed_players(pos_head, dir, def.range, user, bullet_definition.bullet_trail, bullet_definition.pierce)
  if pointed_players then
    block_league.apply_damage(user, pointed_players, bullet_definition.bullet_damage, bullet_definition.knockback, bullet_definition.decrease_damage_with_distance)
  end
end



function block_league.shoot_bullet(name, def, def2, itemstack, user, pointed_thing)
  local yaw = user:get_look_horizontal()
  local pitch = user:get_look_vertical()
  local dir = user:get_look_dir()
  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y + user:get_properties().eye_height, z = pos.z}
  local username = user:get_player_name()
  local bullet_name = nil
  local speed = nil

  if def2 then
    bullet_name = (def2.name and def2.name or name) .. '_entity'
    speed = def2.bullet.bullet_speed + def.launching_force
  else
    bullet_name = (def.name and def.name or name) .. '_entity'
    speed = def.bullet.bullet_speed
  end

  local bullet = minetest.add_entity(pos_head, bullet_name, username)

  bullet:set_velocity({
    x=(dir.x * speed),
    y=(dir.y * speed),
    z=(dir.z * speed),
  })

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

    -- controllo le immunità
    if target:get_inventory():contains_item("main", "arena_lib:immunity") then
      --TODO: sostituire con un suono
      minetest.chat_send_player(p_name, minetest.colorize("#d7ded7", S("You can't hit @1 due to immunity", target:get_player_name())))
    return end

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



function weapon_reload(user, def, name)

  local p_name = user:get_player_name()
  local p_meta = user:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or user:get_hp() <= 0
     or arena.weapons_disabled or def.type == 3 or not def.magazine
     or def.magazine == 0 or p_meta:get_int("bl_reloading") == 1
    then return end

  p_meta:set_int("bl_reloading", 1)

  minetest.after(def.reload_time, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weap_delay", 0)
    p_meta:set_int("bl_reloading", 0)

    arena.players[p_name].weapons_magazine[name] = def.magazine
    block_league.weapons_hud_update(arena, p_name, name, arena.players[p_name].weapons_magazine[name])
  end)

end



local function weapon_right_click(itemstack, player, pointed_thing)
  if not def.on_right_click then return end

  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or player:get_hp() <= 0 or arena.weapons_disabled then return end

  local p_meta = player:get_meta()

  ----- gestione delay dell'arma -----
  if p_meta:get_int("bl_weap_secondary_delay") == 1 or p_meta:get_int("bl_death_delay") == 1 then
    return end

  p_meta:set_int("bl_weap_secondary_delay", 1)

  minetest.after(def.weap_secondary_delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weap_secondary_delay", 0)
  end)
  ----- fine gestione delay -----

  -- se sono immune e sparo, perdo l'immunità
  if player:get_armor_groups().immortal and player:get_armor_groups().immortal == 1 then
    player:set_armor_groups({immortal = nil})
  end

  if def.on_right_click then
    def.on_right_click(arena, name, def, itemstack, player, pointed_thing)
  end
end



function gestione_sparo(p_name, user, def, name)

  if not arena_lib.is_player_in_arena(p_name) then return end

  local arena = arena_lib.get_arena_by_player(p_name)
  local p_meta = user:get_meta()

  ----- gestione delay dell'arma -----
  if p_meta:get_int("bl_weap_delay") == 1 or
     p_meta:get_int("bl_death_delay") == 1 or
     p_meta:get_int("bl_reloading") == 1 then
    return false end

  p_meta:set_int("bl_weap_delay", 1)
  if def.magazine then
    if not arena.players[p_name].weapons_magazine[name] then
      arena.players[p_name].weapons_magazine[name] = 0
    end
  end

  minetest.after(def.weap_delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    if def.magazine and user:get_meta():get_int("bl_reloading") == 0 then
      user:get_meta():set_int("bl_weap_delay", 0)
    elseif not def.magazine then
      user:get_meta():set_int("bl_weap_delay", 0)
    end
  end)
  ----- fine gestione delay -----

  -- se sono immune e sparo, perdo l'immunità
  if user:get_armor_groups().immortal and user:get_armor_groups().immortal == 1 then
    user:set_armor_groups({immortal = nil})
  end

  if user:get_hp() <= 0 or arena.weapons_disabled then return end

  --[[  Per quando si avranno caricatori limitati
  if def.consume_bullets then
    if inv:contains_item("main", def.bullet) then
      inv:remove_item("main", def.bullet)
      block_league.weapons_hud_update(arena, p_name, name)
    else
      return false
    end
  end]]

  -- controllo caricamento
  if def.magazine and def.magazine > 0 then
    arena.players[p_name].weapons_magazine[name] = arena.players[p_name].weapons_magazine[name] - 1
    if arena.players[p_name].weapons_magazine[name] == 0 and user:get_meta():get_int("bl_reloading") == 0 then
      p_meta:set_int("bl_reloading", 1)

      minetest.after(def.reload_time, function()
        if user and user:get_meta() then
          p_meta:set_int("bl_weap_delay", 0)
          p_meta:set_int("bl_reloading", 0)
          arena.players[p_name].weapons_magazine[name] = def.magazine
          block_league.weapons_hud_update(arena, p_name, name, arena.players[p_name].weapons_magazine[name])
        end
      end)
    end
  end

  if def.type and def.type ~= 3 then
    block_league.weapons_hud_update(arena, p_name, name, arena.players[p_name].weapons_magazine[name])
  end
  return true
end



function shoot_generic(def, name, itemstack, user, pointed_thing)

  if def.type ~= 3 then
      local bullet_def = def.bullet and minetest.registered_nodes[def.bullet] or nil

      if def.type == 1 then
        block_league.shoot_hitscan(name, def, bullet_def, itemstack, user, pointed_thing)
      elseif def.type == 2 then
        block_league.shoot_bullet(name, def, bullet_def, itemstack, user, pointed_thing)
      end

  else
      if pointed_thing.type ~= "object" or not pointed_thing.ref:is_player() then return end

      block_league.apply_damage(user, pointed_thing.ref, def.weap_damage, def.knockback, false, user:get_look_dir())
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
