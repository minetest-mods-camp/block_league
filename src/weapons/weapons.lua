local function weapon_left_click() end
local function weapon_right_click() end
local function weapon_zoom() end
local function weapon_reload() end
local function can_use_weapon() end
local function shoot() end
local function shoot_loop() end
local function remove_immunity() end
local function decrease_magazine() end
local function shoot_hitscan() end
local function shoot_bullet() end
local function shoot_melee() end
local function shoot_end() end
local function after_damage() end

-- TODO: la struttura va ripensata in generale, per supportare funzioni principali
-- e secondarie (pensa alle armi di Synthetic Stars). Studiarla prima su carta
-- sapendo come saranno le armi, e solo dopo mettere le mani qui - perché è già
-- abbastanza un macello

-- Appunti: per comunicare a un'arma a fuoco continuo o caricato di smettere di
-- sparare, basta impostare il metadato "bl_is_shooting" a 0, come se fosse un
-- segnale. Questo evita di dichiarare shoot_end() come funzione globale



--v---------------- globalstep -------------------v--
minetest.register_globalstep(function(dtime)
  for _, p_name in pairs(arena_lib.get_players_in_minigame("block_league")) do
    if not arena_lib.is_player_spectating(p_name) then
      local p_data = arena_lib.get_arena_by_player(p_name).players[p_name]
      local player = minetest.get_player_by_name(p_name)
      local w_name = player:get_wielded_item():get_name()
      local curr_weap = p_data.current_weapon

      -- disattivo zoom
      if player:get_fov() == 20 and (w_name ~= "block_league:pixelgun" or player:get_meta():get_int("bl_reloading") == 1) then
        block_league.deactivate_zoom(player)
      end

      -- cambio mirino
      if w_name ~= curr_weap then
        player:get_meta():set_int("bl_is_shooting", 0)
        p_data.current_weapon = w_name
        block_league.HUD_crosshair_update(p_name, w_name)
      end
    end
  end
end)
--^---------------- globalstep -------------------^--



function block_league.register_weapon(name, def)
  -- usato per avere una dichiarazione pulita E al tempo stesso non dover passare
  -- anche il nome in on_use (che lo richiede)
  def.name = name

  local groups

  -- specifica il gruppo per capire come renderizzare l'arma in 3D
  if def.mesh then
    groups = {bl_weapon_mesh = 1}
  elseif def.weapon_type == 3 then
    groups = {bl_sword = 1}
  else
    groups = {bl_weapon = 1}
  end

  minetest.register_node(name, {
    name = def.name,
    groups = groups,

    description = def.description,
    profile_description = def.profile_description or "",
    drawtype = def.mesh and "mesh" or "item",
    mesh = def.mesh or nil,
    tiles = def.tiles or nil,
    wield_image = def.wield_image or nil,
    wield_scale = def.wield_scale,
    inventory_image = def.inventory_image,
    crosshair = def.crosshair,
    use_texture_alpha = def.mesh and "clip" or nil,

    weapon_type = def.weapon_type,

    damage = def.damage,
    weapon_range = def.weapon_range,
    knockback = def.knockback,
    fire_delay = def.fire_delay,
    range = def.range and def.range or 0,
    node_placement_prediction = "", -- disable prediction

    pierce = def.pierce,
    decrease_damage_with_distance = def.decrease_damage_with_distance,
    continuos_fire = def.continuos_fire,
    --charged_shot = def.charged_shot, TODO: per le armi caricate come la pixelgun

    sound_shoot = def.sound_shoot,
    sound_reload = def.sound_reload,
    bullet_trail = def.bullet_trail,

    consume_bullets = def.consume_bullets,
    magazine = def.magazine,
    reload_time = def.reload_time,

    zoom = def.zoom,
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
      weapon_reload(user, def)
    end

  })
end



-- può avere uno o più obiettivi: formato ObjectRef
function block_league.apply_damage(user, targets, weapon, decrease_damage_with_distance, knockback_dir)
  local damage = weapon.damage
  local knockback = weapon.knockback
  local p_name = user:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)
  local killed_players = 0

  if not arena or arena.in_queue or arena.in_loading or arena.in_celebration then return end

  if type(targets) ~= "table" then
    targets = {targets}
  end

  local remaining_HP

  -- per ogni giocatore colpito
  for _, target in pairs(targets) do
    local headshot = target.headshot
    local target = target.player

    if target:get_hp() <= 0 then return end
    if target:get_meta():get_int("bl_immunity") == 1 then return end

    local t_name = target:get_player_name()

    -- se giocatorə e obiettivo sono nella stessa squadra, annullo
    if arena_lib.is_player_in_same_team(arena, p_name, t_name) then return end

    -- eventuale spinta
    if knockback > 0 and knockback_dir then
      local knk= vector.multiply(knockback_dir,knockback)
      target:add_velocity(knk)
    end

    -- eventuale colpo in testa
    if headshot and weapon.weapon_type ~= 3 then
      damage = damage * 1.5
      block_league.HUD_critical_show(p_name)
      block_league.sound_play("bl_hit_critical", p_name, "not_overlappable")
    end

    -- eventuale danno decrementato a seconda della distanza
    if weapon.weapon_type == 1 and decrease_damage_with_distance then
      local dist = vector.distance(user:get_pos(), target:get_pos())
      damage = damage - (damage * dist / weapon.weapon_range)
      remaining_HP = target:get_hp() - damage
    else
      remaining_HP = target:get_hp() - damage
    end

    local dmg_table = arena.players[t_name].dmg_received

    -- aggiorno la tabella danni
    dmg_table[p_name] = {
      timestamp = arena.current_time,
      dmg = arena.current_time > dmg_table[p_name].timestamp - 5 and dmg_table[p_name].dmg + damage or damage,
      weapon = weapon.name
    }

    -- applico il danno
    target:set_hp(remaining_HP, {type = "set_hp", player_name = p_name})

    -- se è ancora vivo, riproduco suono danno
    if target:get_hp() > 0 then
      block_league.sound_play("bl_hit", p_name)
    -- sennò kaputt
    else
      block_league.kill(arena, weapon, user, target)
      if t_name ~= p_name then
        killed_players = killed_players +1
      end
    end
  end

  -- calcoli post-danno
  after_damage(arena, p_name, killed_players)
end



function block_league.kill(arena, weapon, player, target)
  local p_name = player:get_player_name()
  local t_name = target:get_player_name()

  -- riproduco suono morte
  block_league.sound_play("bl_kill", p_name)

  if t_name ~= p_name then
    -- informo dell'uccisione
    block_league.HUD_kill_update(p_name, S("YOU'VE KILLED @1", t_name))
    minetest.chat_send_player(t_name, minetest.colorize("#d7ded7", S("You've been killed by @1", minetest.colorize("#eea160", p_name))))

    if arena_lib.is_player_spectated(p_name) then
      for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
        block_league.HUD_kill_update(sp_name, S("@1 HAS KILLED @2", p_name, t_name))
      end
    end

    if arena_lib.is_player_spectated(t_name) then
      for sp_name, _ in pairs(arena_lib.get_player_spectators(t_name)) do
        minetest.chat_send_player(sp_name, minetest.colorize("#d7ded7", S("@1 has been killed by @2", minetest.colorize("#eea160", t_name), minetest.colorize("#eea160", p_name))))
      end
    end

    local p_stats = arena.players[p_name]
    local team_id = p_stats.teamID
    local team = arena.teams[team_id]

    -- aggiungo l'uccisione
    team.kills = team.kills + 1
    p_stats.kills = p_stats.kills + 1

    -- calcolo i punti
    if arena.mode == 1 then
      if player:get_meta():get_int("bl_has_ball") == 1 or target:get_meta():get_int("bl_has_ball") == 1 then
        p_stats.points = p_stats.points + 4
      else
        p_stats.points = p_stats.points + 2
      end
    else
      p_stats.points = p_stats.points + 2
    end

    -- aggiorno HUD
    block_league.info_panel_update(arena, team_id)
    block_league.HUD_spectate_update(arena, p_name, "points")
    block_league.HUD_spectate_update(arena, t_name, "alive")
    block_league.HUD_log_update(arena, weapon.inventory_image, p_name, t_name)

    -- se è DM e il limite è raggiunto, finisce partita
    if arena.mode == 2 then
      block_league.HUD_scoreboard_update_score(arena)
      if team.kills == arena.score_cap then
        local mod = arena_lib.get_mod_by_player(p_name)
        arena_lib.load_celebration(mod, arena, team_id)
      end
    end

  else
    block_league.HUD_kill_update(t_name, S("You've killed yourself"))
    block_league.HUD_log_update(arena, "bl_log_suicide.png", p_name, t_name)
  end
end



function block_league.deactivate_zoom(player)
  --TODO: rimuovere HUD zoom armi
  player:set_fov(0, nil, 0.1)
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function weapon_left_click(weapon, player, pointed_thing)
  if not can_use_weapon(player, weapon) then return end

  --TODO: prob inserire funzione per armi caricate

  shoot(weapon, player, pointed_thing)
end



function weapon_right_click(weapon, player, pointed_thing)
  if not weapon.on_right_click and not weapon.zoom then return end

  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or player:get_hp() <= 0 then return end

  if weapon.zoom then
    weapon_zoom(weapon, player)
    return end

  if arena.weapons_disabled then return end

  local p_meta = player:get_meta()

  ----- gestione delay dell'arma -----
  if p_meta:get_int("bl_weap_delay") == 1 or p_meta:get_int("bl_death_delay") == 1 then
    return end

  p_meta:set_int("bl_weap_delay", 1)

  minetest.after(weapon.weap_secondary_delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weap_delay", 0)
  end)
  ----- fine gestione delay -----

  remove_immunity(player)
  weapon.on_right_click(arena, weapon, player, pointed_thing)
end



function weapon_zoom(weapon, player)
  local p_meta = player:get_meta()

  if p_meta:get_int("bl_reloading") == 1 or p_meta:get_int("bl_death_delay") == 1 then return end

  if player:get_fov() ~= weapon.zoom.fov then
    player:set_fov(weapon.zoom.fov, nil, 0.1)
    -- TODO: applica texture, riproduci suono
  else
    block_league.deactivate_zoom(player)
  end
end



function weapon_reload(player, weapon)
  local w_name = weapon.name
  local p_name = player:get_player_name()
  local p_meta = player:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or not arena.in_game or player:get_hp() <= 0
     or arena.weapons_disabled or weapon.weapon_type == 3 or not weapon.magazine
     or weapon.magazine == 0 or p_meta:get_int("bl_reloading") == 1
     or arena.players[p_name].weapons_magazine[w_name] == weapon.magazine
    then return end

  block_league.sound_play(weapon.sound_reload, p_name)

  p_meta:set_int("bl_is_shooting", 0)
  p_meta:set_int("bl_reloading", 1)

  -- rimuovo eventuale zoom
  if weapon.zoom and player:get_fov() == weapon.zoom.fov then
    block_league.deactivate_zoom(player)
  end

  if p_meta:get_int("bl_is_speed_locked") == 0 then
    player:set_physics_override({ speed = block_league.SPEED_LOW })
  end

  block_league.HUD_weapons_update(arena, p_name, w_name, true)
  block_league.HUD_crosshair_update(p_name, w_name, true)

  minetest.after(weapon.reload_time, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weap_delay", 0) --TODO: perché viene azzerato qui?
    p_meta:set_int("bl_reloading", 0)

    if p_meta:get_int("bl_is_speed_locked") == 0 then
      local vel = arena.players[p_name].stamina > 0 and block_league.SPEED or block_league.SPEED_LOW
      player:set_physics_override({ speed = vel })
    end

    local p_data = arena.players[p_name]
    local curr_weap = p_data.current_weapon

    p_data.weapons_magazine[w_name] = weapon.magazine
    block_league.HUD_weapons_update(arena, p_name, w_name, false)
    block_league.HUD_crosshair_update(p_name, curr_weap, false)
  end)

end



function can_use_weapon(player, weapon)
  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name) then return end

  local p_meta = player:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)
  local w_name = weapon.name

  if player:get_hp() <= 0 or
     arena.weapons_disabled or
     (weapon.magazine and weapon.magazine <= 0) then
    return end

  ----- gestione delay dell'arma -----
  if p_meta:get_int("bl_weap_delay") == 1 or
     p_meta:get_int("bl_death_delay") == 1 or
     p_meta:get_int("bl_reloading") == 1 then
    return end

  p_meta:set_int("bl_weap_delay", 1)

  -- per le armi bianche, aggiorno l'HUD qui che segnala che son state usate
  if not weapon.magazine then
    block_league.HUD_weapons_update(arena, p_name, w_name, true)
    block_league.HUD_crosshair_update(p_name, w_name, true)
  end

  minetest.after(weapon.fire_delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    if weapon.magazine and p_meta:get_int("bl_reloading") == 0 then
      p_meta:set_int("bl_weap_delay", 0)
    elseif not weapon.magazine then
      local curr_weap = arena.players[p_name].current_weapon
      block_league.HUD_weapons_update(arena, p_name, w_name, false)
      block_league.HUD_crosshair_update(p_name, curr_weap, false)
      p_meta:set_int("bl_weap_delay", 0)
    end
  end)

  return true
end



function shoot(weapon, player, pointed_thing)
  if player:get_meta():get_int("bl_is_speed_locked") == 0 then
    player:set_physics_override({ speed = block_league.SPEED_LOW })
  end

  player:get_meta():set_int("bl_is_shooting", 1)

  shoot_loop(weapon, player, pointed_thing)
end



function shoot_loop(weapon, player, pointed_thing)
  local p_name = player:get_player_name()

  block_league.sound_play(weapon.sound_shoot, p_name)

  remove_immunity(player)
  decrease_magazine(player, weapon)

  if weapon.weapon_type == 1 then
    shoot_hitscan(player, weapon, pointed_thing)
  elseif weapon.weapon_type == 2 then
    shoot_bullet(player, weapon.bullet, pointed_thing)
  else
    shoot_melee(player, weapon, pointed_thing)
  end

  -- interrompo lo sparo, se non è un'arma a fuoco continuo
  if not weapon.continuos_fire then return end

  minetest.after(0.1, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    if player:get_player_control().LMB and player:get_meta():get_int("bl_is_shooting") == 1 then
      shoot_loop(weapon, player, pointed_thing)
    else
      shoot_end(player, weapon)
    end
  end)
end



function remove_immunity(player)
  if player:get_meta():get_int("bl_immunity") == 1 then
    player:get_meta():set_int("bl_immunity", 0)
  end
end



function decrease_magazine(player, weapon)
  if not weapon.magazine or weapon.magazine <= 0 then return end

  local w_name = weapon.name
  local p_name = player:get_player_name()
  local p_meta = player:get_meta()
  local arena = arena_lib.get_arena_by_player(p_name)

  arena.players[p_name].weapons_magazine[w_name] = arena.players[p_name].weapons_magazine[w_name] - 1

  -- automatically reload if the magazine is now empty
  if arena.players[p_name].weapons_magazine[w_name] == 0 and p_meta:get_int("bl_reloading") == 0 then
    weapon_reload(player, weapon)
  else
    block_league.HUD_weapons_update(arena, p_name, w_name)
  end
end



function shoot_hitscan(user, weapon, pointed_thing)
  local dir = user:get_look_dir()
  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
  local pointed_players = block_league.get_pointed_players(pos_head, dir, weapon.weapon_range, user, weapon.bullet_trail, weapon.pierce)

  if pointed_players then
    block_league.apply_damage(user, pointed_players, weapon, weapon.decrease_damage_with_distance)
  end
end



function shoot_bullet(user, bullet, pointed_thing)
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



function shoot_melee(player, weapon, pointed_thing)
  if pointed_thing.type ~= "object" or not pointed_thing.ref:is_player() then return end
  local target = {{player = pointed_thing.ref, headshot = false}}
  block_league.apply_damage(player, target, weapon, false, player:get_look_dir())
end



function shoot_end(player, weapon)
  local p_name = player:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)
  local p_meta = player:get_meta()

  p_meta:set_int("bl_is_shooting", 0)

  minetest.after(0.5, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league")
      or arena.players[p_name].stamina == 0
      or p_meta:get_int("bl_reloading") == 1
      or p_meta:get_int("bl_is_shooting") == 1
      or p_meta:get_int("bl_is_speed_locked") == 1
      then return end

    player:set_physics_override({ speed = block_league.SPEED })
  end)
end



function after_damage(arena, p_name, killed_players)
  -- eventuale prestigio doppia/tripla uccisione
  if killed_players > 1 then

    if killed_players == 2 then
      block_league.add_achievement(p_name, 1)
    elseif killed_players >= 3 then
      block_league.add_achievement(p_name, 2)
    end

    arena_lib.send_message_in_arena(arena, minetest.colorize("#eea160", p_name .. " ") .. minetest.colorize("#d7ded7", S("has killed @1 players in a row!", killed_players)))
  end
end
