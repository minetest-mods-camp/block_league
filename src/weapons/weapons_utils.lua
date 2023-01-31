local function draw_particles() end



-- TODO: split particle trails from this function

-- ritorna un array di giocatori con il numero di giocatori trovati a indice 1.
-- Se non trova giocatori diversi da se stesso ritorna nil
function block_league.get_pointed_players(head_pos, dir, range, user, particle, has_piercing)

	local p1 = vector.add(head_pos, vector.multiply(dir, 0))
	local p2 = vector.add(head_pos, vector.multiply(dir, range))

	local ray = minetest.raycast(p1, p2, true, false)
	local players = {}

  -- controllo su ogni cosa attraversata dal raycast (p1 a p2)
	for hit in ray do
    -- se è un oggetto
		if hit.type == "object" then
      -- che è un giocatore
			if hit.ref and hit.ref:is_player() then
        -- e non è colui che spara
				if hit.ref ~= user then
          if (hit.intersection_point.y - hit.ref:get_pos().y) > 1.275 then
            table.insert(players, {player=hit.ref, headshot=true})
          else
            table.insert(players, {player=hit.ref, headshot=false})
          end
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
          if has_piercing then
            if particle ~= nil then
              local impact_dist = vector.distance(head_pos, hit.intersection_point)
              draw_particles(particle, dir, p1, range, impact_dist)
            end
            return players
          else
            if particle ~= nil then
              local impact_dist = vector.distance(head_pos, players[1].player:get_pos())
              draw_particles(particle, dir, p1, range, impact_dist)
            end
            return {players[1]}
          end
				else
          if particle ~= nil then
            local impact_dist = vector.distance(head_pos, hit.intersection_point)
            draw_particles(particle, dir, p1, range, impact_dist)
          end
					return nil
				end
      end
		end
	end

  -- se ho sparato a qualcuno senza incrociare blocchi
  if #players > 0 then
      if has_piercing then
        if particle ~= nil then
          draw_particles(particle, dir, p1, range, 120)
        end
        return players
      else
        if particle ~= nil then
          local impact_dist = vector.distance(head_pos, players[1].player:get_pos())
          draw_particles(particle, dir, p1, range, impact_dist)
        end
        return {players[1]}
      end
  else
    if particle ~= nil then
      draw_particles(particle, dir, p1, range, 120)
    end
    return nil
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

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





------------------------------
-- not my code, don't know, don't ask
------------------------------

block_league.explode = function(self)
  local explosion_range = self.initial_properties.explosion_range
  local explosion_damage = self.initial_properties.explosion_damage
  local origin = self.object:get_pos()
  local p_name = self.p_name
  if origin == nil then return end
  if origin.x == nil or origin.y == nil or origin.z == nil then return end

  local objs = minetest.env:get_objects_inside_radius(origin, explosion_range)
  local entities = {}
  -- Se ho colpito qualcosa
  if objs then
    for _, obj in ipairs(objs) do
      if obj:is_player() then

        local p_pos = obj:get_pos()
        local lenx = math.abs(p_pos.x - origin.x)
        local leny = math.abs(p_pos.y - origin.y)
        local lenz = math.abs(p_pos.z - origin.z)
        local hypot = math.sqrt((lenx * lenx) + (lenz * lenz))
        local dist = math.sqrt((hypot * hypot) + (leny * leny))
        local damage = explosion_damage - (explosion_damage * dist / explosion_range)
        local target_name = obj:get_player_name()


        if self.old_p_name and p_name == target_name then
          p_name = self.old_p_name
        end

        -- Se colpisco me stesso, prendo 1/5 di danno
        if (target_name ~= p_name) then
          -- TODO: non funziona, la funzione è stata cambiata. Bisogna far passare l'arma
          block_league.apply_damage(minetest.get_player_by_name(p_name), obj, damage, 0, false)
        else
          block_league.apply_damage(minetest.get_player_by_name(p_name), obj, (damage/5), 0, false)
        end

      elseif obj ~= self.object and obj:get_luaentity() then
        local entity = obj:get_luaentity()
        table.insert(entities, entity)
      end
    end
  end

  if #entities == 0 then return end
  self.object:remove()
  for _,entity in pairs(entities) do
    if entity.initial_properties ~= nil then
      if entity.initial_properties.is_bullet then

        entity.old_p_name = entity.p_name
        entity.p_name = p_name

        entity:_destroy()

      end
    end
  end
end


block_league.grenade_explode = function(self)
  local explosion_range = self.initial_properties.explosion_range
  local explosion_damage = self.initial_properties.explosion_damage
  local origin = self.object:get_pos()
  local p_name = self.p_name
  if origin == nil then return end
  if origin.x == nil or origin.y == nil or origin.z == nil then return end

  local objs = minetest.env:get_objects_inside_radius(origin, explosion_range)
  local entities = {}
  -- Se ho colpito qualcosa
  if objs then
    for _, obj in ipairs(objs) do
      if obj:is_player() then

        local p_pos = obj:get_pos()
        local lenx = math.abs(p_pos.x - origin.x)
        local leny = math.abs(p_pos.y - origin.y)
        local lenz = math.abs(p_pos.z - origin.z)
        local hypot = math.sqrt((lenx * lenx) + (lenz * lenz))
        local dist = math.sqrt((hypot * hypot) + (leny * leny))
        local damage = explosion_damage - (explosion_damage * dist / explosion_range)
        local target_name = obj:get_player_name()

        if self.old_p_name and p_name == target_name then
          p_name = self.old_p_name
        end

        -- TODO: non funziona, la funzione è stata cambiata. Bisogna far passare l'arma
        block_league.apply_damage(minetest.get_player_by_name(p_name), obj, damage, 0, false)

      elseif obj ~= self.object and obj:get_luaentity() then

        local entity = obj:get_luaentity()
        table.insert(entities, entity)
      end
    end
  end

  if #entities == 0 then return end
  self.object:remove()
  for _,entity in pairs(entities) do
    if entity.initial_properties ~= nil then
      if entity.initial_properties.is_bullet then

        entity.old_p_name = entity.p_name
        entity.p_name = p_name

        entity:_destroy()

      end
    end
  end
end
