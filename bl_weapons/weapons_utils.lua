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
