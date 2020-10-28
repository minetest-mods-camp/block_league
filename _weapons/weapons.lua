local function weapon_reload() end
local function gestione_sparo() end
local function shoot_generic() end
local function after_shoot() end
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
    reload = def.reload or nil,

    -- Q = reload
    on_drop = function(itemstack, user, pointed_thing)
      weapon_reload(user, def, name)
    end,

    -- RMB = secondary use
    on_place = function(itemstack, user, pointed_thing)

      if not def.on_right_click then return end
      ----- gestione delay dell'arma -----
      if user:get_meta():get_int("blockleague_weap_secondary_delay") == 1 or
        user:get_meta():get_int("blockleague_death_delay") == 1 then
      return end

      user:get_meta():set_int("blockleague_weap_secondary_delay", 1)

      local inv = user:get_inventory()

      minetest.after(def.weap_secondary_delay, function()
        if user then
          if inv:contains_item("main", "block_league:match_over") then return end
          user:get_meta():set_int("blockleague_weap_secondary_delay", 0)
        end
      end)
      ----- fine gestione delay -----

      -- se sono immune e sparo, perdo l'immunità
      if user:get_armor_groups().immortal and user:get_armor_groups().immortal == 1 then
        user:set_armor_groups({immortal = nil})
      end

      local p_name = user:get_player_name()
      local arena = arena_lib.get_arena_by_player(p_name)

      if not arena or not arena.in_game or user:get_hp() <= 0 or arena.weapons_disabled then return end

      if def.on_right_click then
        def.on_right_click(arena, name, def, itemstack, user, pointed_thing)
      end
    end,

    -- LMB = first fire
    on_use = function(itemstack, user, pointed_thing)

      local p_name = user:get_player_name()

      if not gestione_sparo(p_name, user, def, name, nil) then return end

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

          local inv = player:get_inventory()

          local wielditem = player:get_wielded_item()
          if wielditem:get_name()==name then
           local p_name = player:get_player_name()

           if not gestione_sparo(p_name, player, def, name, inv) then return end

           if def.weap_sound_shooting then
             -- riproduzione suono
             minetest.sound_play(def.weap_sound_shooting, {
                 to_player = p_name,
                 max_hear_distance = 5,
             })
           end

           shoot_generic(def, p_name, itemstack, player, pointed_thing)

         elseif def.slow_down_when_firing and player:get_meta():get_int("blockleague_has_ball") == 0 and arena_lib.is_player_in_arena(p_name) then
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
          local inv = player:get_inventory()
          local wielditem = player:get_wielded_item()
          if wielditem:get_name()==name then

            if def.slow_down_when_firing and player:get_meta():get_int("blockleague_has_ball") == 0 then
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
          elseif def.slow_down_when_firing and player:get_meta():get_int("blockleague_has_ball") == 0 and arena_lib.is_player_in_arena(player:get_player_name()) then
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

    on_secondary_use = function(itemstack, user, pointed_thing)
      if not def.on_right_click then return end
      ----- gestione delay dell'arma -----
      if user:get_meta():get_int("blockleague_weap_secondary_delay") == 1 or
        user:get_meta():get_int("blockleague_death_delay") == 1 then
      return end

      user:get_meta():set_int("blockleague_weap_secondary_delay", 1)

      local inv = user:get_inventory()

      minetest.after(def.weap_secondary_delay, function()
        if user then
          if inv:contains_item("main", "block_league:match_over") then return end
          user:get_meta():set_int("blockleague_weap_secondary_delay", 0)
        end
      end)
      ----- fine gestione delay -----

      -- se sono immune e sparo, perdo l'immunità
      if user:get_armor_groups().immortal and user:get_armor_groups().immortal == 1 then
        user:set_armor_groups({immortal = nil})
      end


      local p_name = user:get_player_name()

      -- Check if the player is in the arena and is fighting, if not it exits
      if not arena_lib.is_player_in_arena(p_name) then return end

      local arena = arena_lib.get_arena_by_player(p_name)

      if not arena or not arena.in_game or user:get_hp() <= 0 or arena.weapons_disabled then return end

      if def.on_right_click then
        def.on_right_click(arena, name, def, itemstack, user, pointed_thing)
      end
    end,

  })

end



function block_league.shoot_hitscan(name, def, bullet_definition, itemstack, user, pointed_thing)
  local dir = user:get_look_dir()
  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
  local pointed_players = block_league.get_pointed_players(pos_head, dir, 0, def.range, user, bullet_definition.bullet_trail, bullet_definition.impaling)
  if pointed_players then
    block_league.shoot(user, pointed_players, bullet_definition.bullet_damage, bullet_definition.knockback, bullet_definition.decrease_damage_with_distance)
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

  --local rotation = vector.new(0, yaw + math.pi/2, pitch + math.pi/6)
  local rotation = ({x = -pitch, y = yaw, z = 0})
  bullet:set_rotation(rotation)


end



function block_league.get_dist(pos1, pos2)
  local lenx = math.abs(pos1.x - pos2.x)
  local leny = math.abs(pos1.y - pos2.y)
  local lenz = math.abs(pos1.z - pos2.z)
  local hypot = math.sqrt((lenx * lenx) + (lenz * lenz))
  local dist = math.sqrt((hypot * hypot) + (leny * leny))
  return dist
end

--Ritorna la direzione da un punto ad un altro.
function block_league.get_dir_from_pos(pos1, pos2)
  local dir = vector.subtract(pos1,pos2)
  return dir
end



-- ritorna un array di player con il numero di player trovati a index 1. Se non
-- trova player diversi da se stessi ritorna nil
function block_league.get_pointed_players(head_pos, dir, dist1, dist2, user, particle, trafigge)
	local p1 = vector.add(head_pos, vector.multiply(dir, dist1))
  --block_league.mostra_posizione(p1, 100)
	local p2 = vector.add(head_pos, vector.multiply(dir, dist2))
  --block_league.mostra_posizione(p2, 100)
	local ray = minetest.raycast(p1, p2, true, false)

	local players = {}

  -- check su ogni cosa attraversata dal raycast (p1 a p2)
	for hit in ray do
    -- se è un oggetto
		if hit.type == "object" then
      if hit.ref then
      -- se è un giocatore
  			if hit.ref:is_player() then
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
      end
		else
      -- se è un nodo mi fermo, e ritorno l'array se > 0 (ovvero ha trovato giocatori)
			if hit.type == "node" then
				if #players > 0 then
          if particle ~= nil and particle ~= false then
            if not trafigge then
              local dist3 = block_league.get_dist(head_pos, players[1]:get_pos())
              minetest.add_particlespawner({
                amount = particle.amount,
                time = 0.3,
                minpos = p1,
                maxpos = p1,
                minvel = vector.multiply(dir, dist2),
                maxvel = vector.multiply(dir, dist2),
                minexptime = dist3/(dist2 * 1.5),
                maxexptime = dist3/(dist2 * 1.5),
                size = 2,
                collisiondetection = false,
                vertical = false,
                texture = particle.image,
                --texture = "block_league_pixelgun_trail.png"
              })
            else
              local dist3 = block_league.get_dist(head_pos, hit.intersection_point)
            	minetest.add_particlespawner({
              	amount = particle.amount,
              	time = 0.3,
              	minpos = p1,
              	maxpos = p1,
              	minvel = vector.multiply(dir, dist2),
              	maxvel = vector.multiply(dir, dist2),
              	minexptime = dist3/(dist2 * 1.5),
              	maxexptime = dist3/(dist2 * 1.5),
              	size = 2,
              	collisiondetection = false,
              	vertical = false,
                texture = particle.image,
                --texture = "block_league_pixelgun_trail.png"
            	})
            end
          end
					return players
				else
          if particle ~= nil and particle ~= false then
            local dist3 = block_league.get_dist(head_pos, hit.intersection_point)
          	minetest.add_particlespawner({
            	amount = particle.amount,
            	time = 0.3,
            	minpos = p1,
            	maxpos = p1,
            	minvel = vector.multiply(dir, dist2),
            	maxvel = vector.multiply(dir, dist2),
            	minexptime = dist3/(dist2 * 1.5),
            	maxexptime = dist3/(dist2 * 1.5),
            	size = 2,
            	collisiondetection = false,
            	vertical = false,
              texture = particle.image,
              --texture = "block_league_pixelgun_trail.png"
          	})
          end
					return nil
				end
      end
		end
	end

  -- se ho sparato a qualcuno puntando in aria (quindi senza incrociare blocchi)
	if #players > 0 then
    if trafigge then
      if particle ~= nil and particle ~= false then
      	minetest.add_particlespawner({
        	amount = particle.amount,
        	time = 0.3,
        	minpos = p1,
        	maxpos = p1,
        	minvel = vector.multiply(dir, 120),
        	maxvel = vector.multiply(dir, 120),
        	minexptime = dist2/120,
        	maxexptime = dist2/120,
        	size = 2,
        	collisiondetection = false,
        	vertical = false,
          texture = particle.image,
          --texture = "block_league_pixelgun_trail.png"
      	})
      end
  		return players
    else
      if particle ~= nil and particle ~= false then

        local dist3 = block_league.get_dist(head_pos, players[1]:get_pos())
        minetest.add_particlespawner({
          amount = particle.amount,
          time = 0.3,
          minpos = p1,
          maxpos = p1,
          minvel = vector.multiply(dir, dist2),
          maxvel = vector.multiply(dir, dist2),
          minexptime = dist3/(dist2 * 1.5),
          maxexptime = dist3/(dist2 * 1.5),
          size = 2,
          collisiondetection = false,
          vertical = false,
          texture = particle.image,
          --texture = "block_league_pixelgun_trail.png"
        })

      end
      return {players[1]}
    end
	else
    if particle ~= nil and particle ~= false then
      minetest.add_particlespawner({
        amount = particle.amount,
        time = 0.3,
        minpos = p1,
        maxpos = p1,
        minvel = vector.multiply(dir, 120),
        maxvel = vector.multiply(dir, 120),
        minexptime = dist2/120,
        maxexptime = dist2/120,
        size = 2,
        collisiondetection = false,
        vertical = false,
        texture = particle.image,
        --texture = "block_league_pixelgun_trail.png"
      })
    end
    return nil
  end
end



--block_league.shoot(user, pointed_players, bullet_definition.bullet_damage, bullet_definition.knockback, bullet_definition.decrease_damage_with_distance)
-- può avere uno o più target: formato ObjectRef
function block_league.shoot(user, targets, damage, knockback, decrease_damage_with_distance, knockback_dir)
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
      minetest.sound_play("block_league_hit", {
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
  after_shoot(arena, p_name, killed_players)
end



function block_league.add_default_weapons(inv, arena)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun", "block_league:bouncer"}
  for i, weapon_name in pairs(default_weapons) do
    inv:add_item("main", ItemStack(weapon_name))
  end
end



function block_league.remove_default_weapons(inv, arena)
  local default_weapons = {"block_league:smg", "block_league:sword", "block_league:pixelgun", "block_league:bouncer"}
  for i, weapon_name in pairs(default_weapons) do
    inv:remove_item("main", ItemStack(weapon_name .. "99"))
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function weapon_reload(user, def, name)
  local p_name = user:get_player_name()

  if not arena_lib.is_player_in_arena(p_name) then return false end

  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or user:get_hp() <= 0 or arena.weapons_disabled then return end

  if def.type == 3 then return end

  if def.reload and def.reload > 0 and user:get_meta():get_int("reloading") == 0 then
    user:get_meta():set_int("reloading", 1)
    minetest.after(def.reload_delay, function()
      if user and user:get_meta() then
        local inv = user:get_inventory()
        if inv:contains_item("main", "block_league:match_over") then return false end
        user:get_meta():set_int("blockleague_weap_delay", 0)
        user:get_meta():set_int("reloading", 0)
        block_league.weapons_hud_update(arena, p_name, name, nil, def.reload)
        arena.players[p_name].weapons_reload[name] = 0
      end
    end)

  end

end



function gestione_sparo(p_name, user, def, name, inv)
  -- Check if the player is in the arena and is fighting, if not it exits
  if not arena_lib.is_player_in_arena(p_name) then return false end

  local arena = arena_lib.get_arena_by_player(p_name)

  ----- gestione delay dell'arma -----
  if user:get_meta():get_int("blockleague_weap_delay") == 1 or
  user:get_meta():get_int("blockleague_death_delay") == 1 or
  user:get_meta():get_int("reloading") == 1 then
    return false end

  user:get_meta():set_int("blockleague_weap_delay", 1)
  if def.reload then
    if not arena.players[p_name].weapons_reload[name] then
      arena.players[p_name].weapons_reload[name] = 0
    end
  end

  if not inv then
    inv = user:get_inventory()
  end

  minetest.after(def.weap_delay, function()
    if user and user:get_meta() then
      if inv:contains_item("main", "block_league:match_over") then return false end
      if def.reload and user:get_meta():get_int("reloading") == 0 then
        user:get_meta():set_int("blockleague_weap_delay", 0)
      elseif not def.reload then
        user:get_meta():set_int("blockleague_weap_delay", 0)
      end
    end
  end)
  ----- fine gestione delay -----

  -- se sono immune e sparo, perdo l'immunità
  if user:get_armor_groups().immortal and user:get_armor_groups().immortal == 1 then
    user:set_armor_groups({immortal = nil})
  end


  if not arena or not arena.in_game or user:get_hp() <= 0 or arena.weapons_disabled then return false end

  if def.consume_bullets then
    if inv:contains_item("main", def.bullet) then
      inv:remove_item("main", def.bullet)
      block_league.weapons_hud_update(arena, p_name, name, nil, nil)
    else
      return false
    end
  end

  if def.reload and def.reload > 0 then
    arena.players[p_name].weapons_reload[name] = arena.players[p_name].weapons_reload[name] + 1
    if arena.players[p_name].weapons_reload[name] == def.reload and user:get_meta():get_int("reloading") == 0  then
      user:get_meta():set_int("reloading", 1)
      minetest.after(def.reload_delay, function()
        if user and user:get_meta() then
          if inv:contains_item("main", "block_league:match_over") then return false end
          user:get_meta():set_int("blockleague_weap_delay", 0)
          user:get_meta():set_int("reloading", 0)
          block_league.weapons_hud_update(arena, p_name, name, nil, def.reload)
          arena.players[p_name].weapons_reload[name] = 0
        end
      end)
    end
  end

  if def.type and def.type ~= 3 then
    block_league.weapons_hud_update(arena, p_name, name, nil, nil)
  end
  return true
end



function shoot_generic(def, name, itemstack, user, pointed_thing)
  if def.type == 1 or def.type == 2 then
      local bullet_definition = def.bullet and minetest.registered_nodes[def.bullet] or nil
      if def.type == 1 then
          block_league.shoot_hitscan(name, def, bullet_definition, itemstack, user, pointed_thing)
      elseif def.type == 2 then
          block_league.shoot_bullet(name, def, bullet_definition, itemstack, user, pointed_thing)
      end
  elseif def.type == 3 then
      if pointed_thing.type == "object" and pointed_thing.ref:is_player() then
          local dir = user:get_look_dir()
          block_league.shoot(user, pointed_thing.ref, def.weap_damage, def.knockback, false, dir)
      end
  end
end



function after_shoot(arena, p_name, killed_players)

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
  minetest.sound_play("block_league_kill", {
    to_player = p_name,
    max_hear_distance = 1,
  })

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
      block_league.HUD_teams_score_update(arena, pl_name, p_stats.teamID)
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
