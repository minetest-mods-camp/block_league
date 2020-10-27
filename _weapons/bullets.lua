 function block_league.register_bullet(name, def)
   minetest.register_node(name,{
     name = name,
     description = def.description,
     inventory_image = def.inventory_image,
     wield_scale = def.wield_scale,

     drawtype = def.mesh and "mesh" or "item",
     mesh = def.mesh or nil,
     tiles = def.tiles or nil,
     wield_image = def.wield_image or nil,

     impaling = def.impaling,
     knockback = def.knockback,
     decrease_damage_with_distance = def.decrease_damage_with_distance,
     bullet_damage = def.bullet_damage,
     bullet_trail = def.bullet_trail,
     bullet = def.bullet,

     stack_max = def.stack_max,
     on_drop = function() end,
     on_place = function(itemstack, user, pointed_thing)
       if def.throwable_by_hand then
         local inv = user:get_inventory()

         -- se sono immune e sparo, perdo l'immunità
         if user:get_armor_groups().immortal and user:get_armor_groups().immortal == 1 then
           user:set_armor_groups({immortal = nil})
         end


         local p_name = user:get_player_name()

         -- Check if the player is in the arena and is fighting, if not it exits
         if not arena_lib.is_player_in_arena(p_name) then return end

         local arena = arena_lib.get_arena_by_player(p_name)

         if not arena or not arena.in_game or user:get_hp() <= 0 or arena.weapons_disabled then return end

         if def.consume_on_throw then
           itemstack:take_item()
         end

         block_league.shoot_bullet(name, def, nil, itemstack, user, pointed_thing)
       end
       return itemstack
     end,

     on_secondary_use = function(itemstack, user, pointed_thing)
       if def.throwable_by_hand then
         local inv = user:get_inventory()

         -- se sono immune e sparo, perdo l'immunità
         if user:get_armor_groups().immortal and user:get_armor_groups().immortal == 1 then
           user:set_armor_groups({immortal = nil})
         end

         local p_name = user:get_player_name()

         -- Check if the player is in the arena and is fighting, if not it exits
         if not arena_lib.is_player_in_arena(p_name) then return end

         local arena = arena_lib.get_arena_by_player(p_name)

         if not arena or not arena.in_game or user:get_hp() <= 0 or arena.weapons_disabled then return end

         if def.consume_on_throw then
           itemstack:take_item()
         end

         block_league.shoot_bullet(name, def, nil, itemstack, user, pointed_thing)
       end
       return itemstack
     end,

   })

   if def.shootable then
     -- Ottiene la definizione dell'entità
     local bullet_entity = bullet_set_entity(name, def)
     -- Registra l'entità
     minetest.register_entity(name .. "_entity", bullet_entity)
   end
end

function bullet_set_entity(name, def)
  local bullet_entity = {
    initial_properties = {
      name = name,
      bullet_speed = def.bullet.bullet_speed,
      bullet_explosion_damage = def.bullet.bullet_explosion_damage,
      physical = true,
      collide_with_objects = true,
      visual_size = def.bullet.visual_size,
      collisionbox = def.bullet.collisionbox,

      visual = def.bullet.mesh and "mesh" or "item",
      mesh = def.bullet.mesh,
      textures = def.bullet.textures,
      wield_item = name,
      bullet_explosion_texture = def.bullet.bullet_explosion_texture,
      bullet_speed = def.bullet.bullet_speed,
      explode_on_contact = def.bullet.explode_on_contact,
      bullet_explosion_range = def.bullet.bullet_explosion_range,
      gravity = def.bullet.gravity,
      on_right_click = def.bullet.on_right_click,
      on_destroy = def.bullet.on_destroy,
      duration = def.duration,
      bullet_trail = def.bullet_trail,
      bullet_damage = def.bullet_damage,
      is_bullet = true
    }
  }

  function bullet_entity:_destroy()
    -- Crea le particelle dell'esplosione
    spawn_particles_sphere(self.object:get_pos(), self.initial_properties.bullet_explosion_texture)
    -- Se ha una funzione apposita da usare quando esplode la esegue
    if self.initial_properties.on_destroy then
       self.initial_properties.on_destroy(self)
    end

   -- Distrugge l'entità
   self.object:remove()
  end

  -- Ottiene gli staticdata ogni 18 secondi circa
  function bullet_entity:get_staticdata(self)
    if self == nil or self.p_name == nil then return end
    return self.p_name
  end

  -- L'entità esplode quando colpita
  function bullet_entity:on_punch()
    if self.initial_properties.on_right_click then
       self.initial_properties.on_right_click(self)
    end
  end

  -- quando si istanzia un'entità
  function bullet_entity:on_activate(staticdata)

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

  function bullet_entity:on_step(dtime, moveresult)
    self.lifetime = self.lifetime  + dtime

    if self.lifetime >= self.initial_properties.duration then
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
                block_league.shoot(minetest.get_player_by_name(self.p_name), collision.object, self.initial_properties.bullet_damage, 0, false)
                buffer_boolean = true
              elseif collision.object:get_player_name() == self.p_name then

                if self.lifetime < (15 / self.initial_properties.bullet_speed) then
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
  return bullet_entity

end

-- Aggiunge le particelle dell'esplosione
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
