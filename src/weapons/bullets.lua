local function bullet_set_entity() end
local function spawn_particles_sphere() end



function block_league.register_bullet(bullet, damage, bullet_trail)
   local bullet_entity = bullet_set_entity(bullet.name, bullet, damage, bullet_trail)

   minetest.register_entity("block_league:" .. bullet.name .. "_entity", bullet_entity)

   return bullet_entity
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function bullet_set_entity(name, def, dmg, trail)
  local bullet = {
    initial_properties = {

      name = def.name,
      visual = def.mesh and "mesh" or "item",
      mesh = def.mesh,
      visual_size = def.visual_size,
      textures = def.textures,
      collisionbox = def.collisionbox,

      damage = dmg,
      speed = def.speed,
      lifetime = def.lifetime,

      explosion_range = def.explosion_range,
      explosion_damage = def.explosion_damage,
      explosion_texture = def.explosion_texture,
      bullet_trail = trail,

      explode_on_contact = def.explode_on_contact,
      gravity = def.gravity,

      on_destroy = def.on_destroy,
      on_right_click = def.on_right_click,

      physical = true,
      collide_with_objects = true,

      is_bullet = true
    }
  }

  function bullet:_destroy()
    -- Crea le particelle dell'esplosione
    spawn_particles_sphere(self.object:get_pos(), self.initial_properties.explosion_texture)

    self.initial_properties.on_destroy(self)
    self.object:remove()
  end



  -- Ottiene gli staticdata ogni 18 secondi circa
  function bullet:get_staticdata(self)
    if self == nil or self.p_name == nil then return end
    return self.p_name
  end



  -- L'entità esplode quando colpita
  function bullet:on_punch()
    if self.initial_properties.on_right_click then
       self.initial_properties.on_right_click(self)
    end
  end



  -- quando si istanzia un'entità
  function bullet:on_activate(staticdata)

    if staticdata ~= "" and staticdata ~= nil then
      self.p_name = staticdata -- nome utente come staticdata
      self.lifetime = 0 -- tempo in aria
      self.sliding = 0 -- se sta scivolando
      self.particle = 0 -- contatore di buffer per le particelle della granata
      self.object:set_armor_groups({immortal = 1}) -- lo imposta come immortale
    else -- se non ci sono gli staticdata necessari allora rimuove l'entità
      self.object:remove()
      return
    end
  end



  function bullet:on_step(dtime, moveresult)
    self.lifetime = self.lifetime  + dtime

    if self.lifetime >= self.initial_properties.lifetime then
      -- ESPLODE
      self:_destroy()
      return
    end
    local obj = self.object
    local velocity = obj:get_velocity()
    local pos = obj:getpos()
    -- Controlla che il timer per mostrare le particelle che tracciano la granata sia superiore al valore definito e che eista una definizione delle particelle da creare
    if self.initial_properties.bullet_trail and self.particle >= self.initial_properties.bullet_trail.interval then
      -- Imposta il timer a 0
      self.particle = 0
      -- Aggiunge le particelle di tracciamento
      minetest.add_particle({
        pos = obj:get_pos(),
        velocity = vector.divide(velocity, 2),
        acceleration = vector.divide(obj:get_acceleration(), -5),
        expirationtime = self.initial_properties.bullet_trail.life,
        size = self.initial_properties.bullet_trail.size,
        collisiondetection = false,
        collision_removal = false,
        vertical = false,
        texture = self.initial_properties.bullet_trail.image,
        glow = self.initial_properties.bullet_trail.glow
      })
    -- Controlla che il timer per mostrare le particelle che tracciano la granata sia inferiore al valore definito e che eista una definizione delle particelle da creare
    elseif self.initial_properties.bullet_trail and self.particle < self.initial_properties.bullet_trail.interval then
      -- Incrementa il timer
      self.particle = self.particle + 1
    end


    if self.initial_properties.explode_on_contact then
      -- controlla se collide con qualcosa
      if moveresult.collides == true then
        local buffer_boolean = false
        for k, collision in pairs(moveresult.collisions) do

          --object è l'oggetto(player/entità) con cui collide il proiettile
          if collision.object then
            --controlla se è un player
            if collision.object:is_player() then

              if collision.object:get_player_name() ~= self.p_name then
                -- TODO: non funziona, la funzione è stata cambiata. Bisogna far passare l'arma
                block_league.apply_damage(minetest.get_player_by_name(self.p_name), collision.object, self.initial_properties.bullet_damage, 0, false)
                buffer_boolean = true
              elseif collision.object:get_player_name() == self.p_name then

                if self.lifetime < (15 / self.initial_properties.speed) then
                  obj:set_velocity({
                    x=(collision.old_velocity.x),
                    y=(collision.old_velocity.y),
                    z=(collision.old_velocity.z),
                  })
                end

              end

            elseif collision.object:get_luaentity() then
              --quando non è un player allora è una entity quindi la memorizzo per alleggerire il numero di accessi
              local entity = collision.object:get_luaentity()
              --i prossimi 2 check servono a verificare l'entità sia un proiettile
              if entity and  entity.initial_properties ~= nil then

                if entity.initial_properties.is_bullet then
                  --distrugge sia il proiettile con cui collide che se stesso
                  buffer_boolean = true
                  entity:_destroy()
                end
              end
            end
          elseif collision.type == "node" then
            buffer_boolean = true
          end

        end
        if buffer_boolean then
          self:_destroy()
          return
        end
      end


    else

      if moveresult.collides and moveresult.collisions[1] and not vector.equals(moveresult.collisions[1].old_velocity, velocity) and vector.distance(moveresult.collisions[1].old_velocity, velocity) > 4 then
        if math.abs(moveresult.collisions[1].old_velocity.x - velocity.x) > 5 then -- Controlla se c'è stata una grande riduzione di velocità
          velocity.x = moveresult.collisions[1].old_velocity.x * (self.initial_properties.gravity and -0.5 or -1) -- Inverte la velocità e la riduce
        end

        if math.abs(moveresult.collisions[1].old_velocity.y - velocity.y) > 5 then -- Controlla se c'è stata una grande riduzione di velocità
          velocity.y = moveresult.collisions[1].old_velocity.y * (self.initial_properties.gravity and -0.3 or -1)  -- Inverte la velocità e la riduce
        end

        if math.abs(moveresult.collisions[1].old_velocity.z - velocity.z) > 5 then -- Controlla se c'è stata una grande riduzione di velocità
          velocity.z = moveresult.collisions[1].old_velocity.z * (self.initial_properties.gravity and -0.5 or -1)  -- Inverte la velocità e la riduce
        end

        obj:set_velocity(velocity)
      end
      if self.initial_properties.gravity then
        if self.sliding == 0 and velocity.y == 0 then -- Controlla se la granata sta scivolando
          self.sliding = 1 -- Attiva l'attrito
        elseif self.sliding > 0 and velocity.y ~= 0 then
          self.sliding = 0 -- Non influisce sull'attrito
        end

        if self.sliding > 1 then -- Sta scivolando?
          if vector.distance(vector.new(), velocity) <= 1 and not vector.equals(velocity, vector.new()) then -- Se la granata si muove a malapena
            obj:set_velocity(vector.new(0, -9.8, 0)) -- Si assicura sia ferma
            obj:set_acceleration(vector.new())
          end
        end
      end
    end

    if self.initial_properties.gravity then
      local direction = vector.normalize(velocity)
      local node = minetest.get_node(pos)
      local speed = vector.length(velocity)
      local drag = math.max(minetest.registered_nodes[node.name].liquid_viscosity, 0.1) * self.sliding -- Ottiene l'attrito generato dal liquido che attraversa
      local yaw = minetest.dir_to_yaw(direction)
      local pitch = math.acos(velocity.y/speed) - math.pi/3
      -- Controlla che il pitch sia un numero
      if tostring(pitch) ~= 'nan' then
        obj:set_rotation({x = 0, y = yaw + math.pi/2, z = pitch}) -- Imposta la rotazione
      end

			local acceleration = vector.multiply(velocity, -drag)

      acceleration.x = acceleration.x  * (self.sliding * 10 * 2 + 1) -- Modifica la x in base a se sta scivolando o meno
			acceleration.y = acceleration.y - 10 * ((7 - drag) / 7) -- Perdita in altezza del proiettile in base all' attrito
      acceleration.z = acceleration.z  * (self.sliding * 10 * 2 + 1) -- Modifica la Z in base a se sta scivolando o meno

      -- Controlla che l'accelerazione sia un numero
      if tostring(acceleration) ~= 'nan' then
				obj:set_acceleration(acceleration) -- Imposta l'accelerazione
      end
    end

  end

  -- Restituisce la definizione dell'entità
  return bullet
end



function spawn_particles_sphere(pos, particle_texture)
  if not pos then return end
  minetest.add_particlespawner({
    amount = 80,
		time = .1,
		minpos = {x=pos.x,y=pos.y,z=pos.z},
		maxpos = {x=pos.x,y=pos.y,z=pos.z},
		minvel = {x=-4, y=-4, z=-4},
 		maxvel = {x=4, y=4, z=4},
 		minacc = {x=0, y=-0.4, z=0},
  	maxacc = {x=0, y=-0.8, z=0},
  	minexptime = .5,
  	maxexptime = .5,
  	minsize = 1,
 		maxsize = 5,
 		collisiondetection = false,
  	vertical = false,
  	texture = particle_texture,
  })
end