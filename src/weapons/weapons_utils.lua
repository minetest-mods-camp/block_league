local function cast_raycast() end
local function get_player_left_dir() end
local function get_player_up_dir() end
local function debug_particles() end



-- per bloccare fisica
local dummy = {
  initial_properties = {
    physical = true,
    collide_with_objects = false,
    visual = "sprite",
    visual_size = {x = 0, y = 0, z = 0},
    -- per debug (e commenta visual_size)
    --textures = { "logo.png" }
  }
}

minetest.register_entity("block_league:dummy", dummy)



-- I cast a 2x2 grid (assisted aim) to prevent the 0.1 delay. The grid value is
-- actually hardcoded because:
-- 1. it works and I don't need more features from it
-- 2. I haven't got enough knowledge about vectors and rotations anyway
function block_league.get_pointed_players(player, range, has_piercing)
  local hit_pointed_things = {}
  local left_dir = get_player_left_dir(player)
  local head_up_dir = get_player_up_dir(player)
  local look_dir = player:get_look_dir()
  local center = player:get_pos() + look_dir + {x=0, y=1.475, z=0}

  local grid_width = 0.2
  local r_amount = 2
  local x_step = (grid_width / r_amount) * (-left_dir)
  local y_step = (grid_width / r_amount) * head_up_dir
  local ray_pos = center + (x_step / r_amount) + (y_step / r_amount)

  for row = 1, r_amount do
    for column = 1, r_amount do
      local pthings = cast_raycast(player, ray_pos, look_dir, range, has_piercing)
      --debug_particles(look_dir, ray_pos, 30)

      if pthings then
        -- rimuovo giocator3 già colpit3 da altro raggio
        for k, possible_target in pairs(pthings) do
          local pl_name = possible_target.player:get_player_name()
          for _, target in pairs(hit_pointed_things) do
            if pl_name == target.player:get_player_name() then
              pthings[k] = nil
              break
            end
          end
        end

        table.insert_all(hit_pointed_things, pthings)
      end

      ray_pos = ray_pos - x_step
    end

     ray_pos = ray_pos - y_step
     ray_pos = ray_pos + x_step * r_amount
  end

  return hit_pointed_things
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

-- ritorna un array di giocatori con il numero di giocatori trovati a indice 1.
-- Se non trova giocatori diversi da se stesso ritorna nil
function cast_raycast(user, origin, dir, range, has_piercing)

	local a = vector.add(origin, vector.multiply(dir, 0))
	local b = vector.add(origin, vector.multiply(dir, range))
	local ray = minetest.raycast(a, b)
	local players = {}

  -- controllo su ogni cosa attraversata dal raycast (da a a b)
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
            return players
          else
            return {players[1]}
          end
				else
					return nil
				end
      end
		end
	end

  -- se ho sparato a qualcuno senza incrociare blocchi
  if #players > 0 then
      if has_piercing then
        return players
      else
        return {players[1]}
      end
  else
    return nil
  end
end



function get_player_left_dir(player)
  local yaw = player:get_look_horizontal()
  local pl_left_dir = vector.new(math.cos(yaw), 0, math.sin(yaw))

  return vector.normalize(pl_left_dir)
end



function get_player_up_dir(player)
  return vector.rotate_around_axis(player:get_look_dir(), get_player_left_dir(player), math.pi/2)
end



function debug_particles(dir, origin, range)
  minetest.add_particlespawner({
    amount = 5,
    time = 0.3,
    pos = vector.new(origin),
    vel = vector.multiply(dir, range),
    size = 2,
    texture = "bl_smg_trail.png"
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
