local S = minetest.get_translator("block_league")

local function register_action() end
local function calc_action() end
local function wait_for_held_action() end
local function wait_for_charged_action() end
local function can_use_weapon() end
local function set_attack_stance() end
local function run_action() end
local function attack_loop() end
local function decrease_magazine() end
local function attack_hitscan() end
local function attack_bullet() end
local function attack_end() end
local function after_damage() end
local function weapon_zoom() end
local function weapon_reload() end
local function draw_particles() end

-- ogni volta che un'arma spara, se il suo ritardo è minore di 0.5s, viene eseguita
-- una funzione dopo 0.5s. Tuttavia, se si spara con un arma con ritardo minore e
-- subito dopo con un'altra (prima dei fatidici 0.5s), quella funzione da 0.5s va
-- annullata. Ne tengo traccia qui
local slow_down_func = {} -- KEY: p_name; VALUE: timer func
local melee_range = block_league.MELEE_RANGE



--v---------------- globalstep -------------------v--
minetest.register_globalstep(function(dtime)
  for _, p_name in pairs(arena_lib.get_players_in_minigame("block_league")) do
    if not arena_lib.is_player_spectating(p_name) then
      local p_data = arena_lib.get_arena_by_player(p_name).players[p_name]
      local player = minetest.get_player_by_name(p_name)
      local w_name = player:get_wielded_item():get_name()
      local curr_weap = p_data.current_weapon

      -- disattivo zoom
      if player:get_fov() == 20 and (w_name ~= "block_league:pixelgun" or player:get_meta():get_int("bl_weapon_state") == 4) then
        block_league.deactivate_zoom(player)
      end

      -- cambio mirino
      if w_name ~= curr_weap and curr_weap then             -- non so perché ma fa circa 2 step con curr_weap `nil` nonostante non ci siano ritardi
        if player:get_meta():get_int("bl_weapon_state") == 2 then
          player:get_meta():set_int("bl_weapon_state", 0)
        end
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
  elseif def.weapon_type == "melee" then
    groups = {bl_sword = 1}
  else
    groups = {bl_weapon = 1}
  end

  minetest.register_node(name, {
    name = def.name,
    groups = groups,

    description = def.description,
    profile_description = def.profile_description or "",
    --TEMP
    action1 = def.action1 or "",
    action2 = def.action2 or "",
    drawtype = def.mesh and "mesh" or "item",
    mesh = def.mesh or nil,
    tiles = def.tiles or nil,
    wield_image = def.wield_image or nil,
    wield_scale = def.wield_scale,
    inventory_image = def.inventory_image,
    crosshair = def.crosshair,
    use_texture_alpha = def.mesh and "clip" or nil,

    weapon_type = def.weapon_type,
    action1       = register_action(def.action1, "LMB"),
    action1_hold  = register_action(def.action1_hold, "LMB"),
    action1_air   = register_action(def.action1_air, "LMB"),
    action2       = register_action(def.action2, "RMB"),
    action2_hold  = register_action(def.action2_hold, "RMB"),
    action2_air   = register_action(def.action2_air, "RMB"),

    magazine = def.magazine,
    reload_time = def.reload_time,
    sound_reload = def.sound_reload,

    range = def.weapon_type == "melee" and melee_range or 0,
    node_placement_prediction = "", -- disable prediction

    -- LMB = first fire
    on_use = function(itemstack, user, pointed_thing)
      calc_action(def, 1, user)
    end,

    -- RMB = secondary fire
    on_secondary_use = function(itemstack, user, pointed_thing)
      calc_action(def, 2, user)
    end,

    on_place = function(itemstack, user, pointed_thing)
      calc_action(def, 2, user)
    end,

    -- Q = reload
    on_drop = function(itemstack, user, pointed_thing)
      weapon_reload(user, def)
    end
  })
end



-- può avere uno o più obiettivi: formato ObjectRef
function block_league.apply_damage(user, targets, weapon, action)
  local knockback = action.knockback
  local killed_players = 0
  local tot_damage = 0      -- in caso di più obiettivi colpiti, sommo tutto il danno per poi fare i calcoli alla fine
  local p_name = user:get_player_name()
  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena or arena.in_queue or arena.in_loading or arena.in_celebration then return end

  if type(targets) ~= "table" then
    targets = {targets}
  end

  local remaining_HP

  -- per ogni giocatore colpito
  for _, target in pairs(targets) do
    local damage = action.damage
    local headshot = target.headshot
    local target = target.player

    if target:get_hp() <= 0 then return end
    if target:get_meta():get_int("bl_immunity") == 1 then return end

    local t_name = target:get_player_name()

    -- se giocatorə e obiettivo sono nella stessa squadra, annullo
    if arena_lib.is_player_in_same_team(arena, p_name, t_name) then return end

    -- eventuale spinta
    if knockback then
      local knk = vector.multiply(user:get_look_dir(), knockback)
      target:add_velocity(knk)
    end

    -- eventuale colpo in testa
    if headshot and action.type ~= "melee" then
      damage = damage * 1.5
      block_league.HUD_critical_show(p_name)
      block_league.sound_play("bl_hit_critical", p_name, "not_overlappable")
    end

    -- eventuale danno decrementato a seconda della distanza
    if action.decrease_damage_with_distance then
      local dist = vector.distance(user:get_pos(), target:get_pos())
      damage = damage - (damage * dist / action.range)
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

    tot_damage = tot_damage + damage
  end

  -- calcoli post-danno
  after_damage(arena, p_name, tot_damage, killed_players)
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

  -- TODO: mettere FOV personalizzato così da evitare questo controllo; essendo un
  -- FPS, è più che sensato
  if not arena_lib.is_player_in_arena(player:get_player_name()) then return end

  local p_meta = player:get_meta()

  if p_meta:get_int("bl_weapon_state") == 0 and
     p_meta:get_int("bl_is_speed_locked") == 0 then
    player:set_physics_override({speed = block_league.SPEED})
  end
end



function block_league.hitter_or_suicide(arena, player, dmg_rcvd_table, no_hitter_img)
  local last_hitter = ""
  local last_hitter_timestamp = 99999

  for pla_name, dmg_data in pairs(dmg_rcvd_table) do
    if arena.current_time > dmg_data.timestamp - 5 and last_hitter_timestamp > dmg_data.timestamp then --TODO crasha se toccano raggi avversari prima di on_start
      last_hitter = pla_name
      last_hitter_timestamp = dmg_data.timestamp
    end
  end

  if last_hitter ~= "" then
    block_league.kill(arena, minetest.registered_nodes[dmg_rcvd_table[last_hitter].weapon], minetest.get_player_by_name(last_hitter), player)
  else
    block_league.HUD_log_update(arena, no_hitter_img, player:get_player_name(), "")
  end
end


----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function register_action(action, key)
  if not action then return end

  action.key = key

  if action.type == "raycast" then
    action.ammo_per_use = action.ammo_per_use or 1
    action.delay = action.delay or 0.5
    action.fire_spread = action.fire_spread or 0
    action.loading_time = action.loading_time or 0
  elseif action.type == "bullet" then
    assert(action.bullet, "Missing bullet in bullet action type")
    block_league.register_bullet(action.bullet, action.damage, action.trail)
  elseif action.type == "punch" then
    assert(action.continuous_fire == nil, "Punch actions can't have continuous fire")
  end

  return action
end



function calc_action(weapon, action_id, player)
  local is_holdable = ((action_id == 1 and weapon.action1_hold) or (action_id == 2 and weapon.action2_hold)) and true
  local in_the_air = weapon.weapon_type == "melee" and block_league.is_in_the_air(player)
  local action

  if not in_the_air and is_holdable then
    local held_key = action_id == 1 and "LMB" or "RMB"
    wait_for_held_action(weapon, held_key, player, 0.3)
    return

  else
    if action_id == 1 then
      action = (in_the_air and weapon.action1_air) and weapon.action1_air or weapon.action1
    else
      action = (in_the_air and weapon.action2_air) and weapon.action2_air or weapon.action2
    end
  end

  if not action or not can_use_weapon(player, weapon, action) then return end

  set_attack_stance(player, action)

  if action.attack_on_release then
    local held_key = action_id == 1 and "LMB" or "RMB"
    wait_for_charged_action(weapon, action, held_key, player, action.load_time, 0)
  --elseif -- TODO: fare separata wait_for_load_action
  else
    run_action(weapon, action, player)
  end
end



function wait_for_held_action(weapon, held_key, player, countdown)
  minetest.after(0.1, function()
    if not can_use_weapon(player, weapon, {}) then return end

    if player:get_player_control()[held_key] then
      if countdown <= 0 then
        local action = held_key == "LMB" and weapon.action1_hold or weapon.action2_hold
        run_action(weapon, action, player)
      else
        countdown = countdown - 0.1
        wait_for_held_action(weapon, held_key, player, countdown)
      end
    else
      local action = held_key == "LMB" and weapon.action1 or weapon.action2
      run_action(weapon, action, player)
    end
  end)
end



function wait_for_charged_action(weapon, action, held_key, player, load_time, time)
  minetest.after(0.1, function()
    if not can_use_weapon(player, weapon, action) then return end

    if player:get_player_control()[held_key] then
      if load_time > time then
        time = time + 0.1
      end

      wait_for_charged_action(weapon, action, held_key, player, load_time, time)
    else
      run_action(weapon, action, player)
    end
  end)
end



function can_use_weapon(player, weapon, action)
  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name) or player:get_hp() <= 0 then return end

  if action.type == "zoom" then return true end

  local arena = arena_lib.get_arena_by_player(p_name)
  local p_meta = player:get_meta()
  local w_magazine = arena.players[p_name].weapons_magazine[weapon.name]

  if p_meta:get_int("bl_weapon_state") ~= 0 or
     p_meta:get_int("bl_death_delay") == 1 or
     arena.weapons_disabled or
     (weapon.magazine and (w_magazine <= 0 or action.ammo_per_use > w_magazine)) then
    return end

  return true
end



function set_attack_stance(player, action)
  local p_meta = player:get_meta()
  local p_name = player:get_player_name()

  if p_meta:get_int("bl_immunity") == 1 then
    p_meta:set_int("bl_immunity", 0)
  end

  if slow_down_func[p_name] then
    slow_down_func[p_name]:cancel()
  end

  if p_meta:get_int("bl_is_speed_locked") == 0 then
    if action.physics_override then
      if action.physics_override == "FREEZE" then
        local p_pos = player:get_pos()
        local p_y = player:get_look_horizontal()
        local dummy = minetest.add_entity(p_pos, "block_league:dummy")
        player:set_attach(dummy, "", {x=0,y=-5,z=0}, {x=0, y=-math.deg(p_y), z=0})
      else
        player:set_physics_override(action.physics_override)
      end

      p_meta:set_int("bl_is_speed_locked", 1)
    else
      player:set_physics_override({ speed = block_league.SPEED_LOW })
    end
  end
end



function run_action(weapon, action, player)
  if action.type == "raycast" or action.type == "bullet" or action.type == "punch" or action.type == "custom" then
    player:get_meta():set_int("bl_weapon_state", 2)
    attack_loop(weapon, action, player)

  elseif action.type == "zoom" then
    weapon_zoom(action, player)

  elseif action.type == "install" then
    player:get_meta():set_int("bl_weapon_state", 2)
    -- TODO

  elseif action.type == "parry" then
    -- player:get_meta():set_int("bl_weapon_state", 5)
  end
end


function attack_loop(weapon, action, player)
  local p_name = player:get_player_name()

  block_league.sound_play(action.sound, p_name)

  if action.type == "punch" then
    attack_hitscan(player, weapon, action)
  elseif action.type == "custom" then
    action.on_use(player, weapon, action)
  else
    decrease_magazine(player, weapon, action.ammo_per_use)

    if action.type == "raycast" then
      attack_hitscan(player, weapon, action)
    elseif action.type == "bullet" then
      attack_bullet(player, weapon.bullet)
    end

  end

  -- interrompo lo sparo se non è un'arma a colpo continuo
  if not action.continuous_fire then
    attack_end(player, weapon, action.delay)

  else
    minetest.after(action.delay, function()
      if not arena_lib.is_player_in_arena(p_name, "block_league") then return end

      local arena = arena_lib.get_arena_by_player(p_name)
      local w_magazine = arena.players[p_name].weapons_magazine[weapon.name]

      if player:get_player_control()[action.key]
        and player:get_meta():get_int("bl_weapon_state") == 2
        and (weapon.magazine and (w_magazine > 0 and action.ammo_per_use <= w_magazine)) then
        attack_loop(weapon, action, player)
      else
        attack_end(player, weapon, action.delay)
      end
    end)
  end
end



function decrease_magazine(player, weapon, amount)
  local p_name = player:get_player_name()
  local w_name = weapon.name
  local arena = arena_lib.get_arena_by_player(p_name)
  local p_data = arena.players[p_name]

  p_data.weapons_magazine[w_name] = p_data.weapons_magazine[w_name] - amount

  -- automatically reload if the magazine is now empty
  if p_data.weapons_magazine[w_name] == 0 then
    weapon_reload(player, weapon)
  else

    block_league.HUD_weapons_update(arena, p_name, w_name)
    return true
  end
end



function attack_hitscan(user, weapon, action)
  local dir = user:get_look_dir()
  local pos = user:get_pos()
  local pos_head = {x = pos.x, y = pos.y+1.475, z = pos.z}
  local pointed_players = block_league.get_pointed_players(user, pos_head, dir, action.range or melee_range, action.pierce)

  if action.trail then
    draw_particles(action.trail, dir, pos_head, action.range, action.pierce)
  end

  if pointed_players then
    block_league.apply_damage(user, pointed_players, weapon, action)
  end
end



function attack_bullet(user, bullet)
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



function attack_end(player, weapon, delay)
  local p_name = player:get_player_name()
  local p_meta = player:get_meta()

  if p_meta:get_int("bl_weapon_state") == 4 then return end

  p_meta:set_int("bl_weapon_state", 3)

  local arena = arena_lib.get_arena_by_player(p_name)
  local w_name = weapon.name

  -- se sono armi bianche, aggiorno l'HUD qui che segnala che son state usate
  if not weapon.magazine then
    block_league.HUD_weapons_update(arena, p_name, w_name, true)
    block_league.HUD_crosshair_update(p_name, w_name, true)
  end

  -- finisce attesa e ripristina eventuale fisica personalizzata
  minetest.after(delay, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end

    if p_meta:get_int("bl_weapon_state") ~= 4 then
      p_meta:set_int("bl_weapon_state", 0)
    end

    -- se ha la fisica personalizzata, ripristinala
    if p_meta:get_int("bl_is_speed_locked") == 1 then
      p_meta:set_int("bl_is_speed_locked", 0)

      if player:get_attach() then
        player:get_attach():remove()

      else
        player:set_physics_override(block_league.PHYSICS)

        if arena.players[p_name].stamina == 0
          or p_meta:get_int("bl_weapon_state") ~= 0
          or player:get_fov() ~= 0 then
          player:set_physics_override({speed = block_league.SPEED_LOW})
        end
      end

    -- TEMP: se `delay` è 0.5, c'è il rischio che la funzione sotto venga chiamata
    -- prima di questa. Serve https://github.com/minetest/minetest/issues/13477
    elseif player:get_physics_override().speed ~= block_league.SPEED
      and arena.players[p_name].stamina > 0
      and p_meta:get_int("bl_weapon_state") == 0
      and player:get_fov() == 0 then
      player:set_physics_override({speed = block_league.SPEED})
    end

    -- ripristino colore HUD per le armi bianche (faccio qui per non aver un terzo after più in alto)
    if not weapon.magazine then
      local curr_weap = arena.players[p_name].current_weapon
      block_league.HUD_weapons_update(arena, p_name, w_name, false)
      block_league.HUD_crosshair_update(p_name, curr_weap, false)
    end
  end)

  -- ripristina velocità dopo 0.5 secondi
  slow_down_func[p_name] = minetest.after(0.5, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league")
      or arena.players[p_name].stamina == 0
      or p_meta:get_int("bl_weapon_sate") ~= 0
      or p_meta:get_int("bl_is_speed_locked") == 1
      or player:get_fov() ~= 0
      then return end

    player:set_physics_override({ speed = block_league.SPEED })
  end)
end



function after_damage(arena, p_name, damage, killed_players)
  -- aggiorno danno totale inflitto ed eventualmente aumento i punti
  local p_data = arena.players[p_name]
  local prev_dmg_dealt = p_data.dmg_dealt
  local dmg_dealt = prev_dmg_dealt + damage
  local dmg_points = math.floor(dmg_dealt/10) - math.floor(prev_dmg_dealt/10)

  if dmg_points > 0 then
    p_data.points = p_data.points + dmg_points
    block_league.info_panel_update(arena, p_data.teamID)
    block_league.HUD_spectate_update(arena, p_name, "points")
  end

  p_data.dmg_dealt = dmg_dealt

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



function weapon_zoom(action, player)
  local p_meta = player:get_meta()

  if player:get_fov() ~= action.fov then
    player:set_fov(action.fov, nil, 0.1)
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
     or arena.weapons_disabled or weapon.weapon_type == "melee" or not weapon.magazine
     or weapon.magazine == 0 or p_meta:get_int("bl_weapon_state") == 4
     or arena.players[p_name].weapons_magazine[w_name] == weapon.magazine
    then return end

  block_league.sound_play(weapon.sound_reload, p_name)

  p_meta:set_int("bl_weapon_state", 4)

  -- rimuovo eventuale zoom
  if weapon.action2.type == "zoom" and player:get_fov() == weapon.action2.fov then
    block_league.deactivate_zoom(player)
  end

  if p_meta:get_int("bl_is_speed_locked") == 0 then
    player:set_physics_override({ speed = block_league.SPEED_LOW })
  end

  block_league.HUD_weapons_update(arena, p_name, w_name, true)
  block_league.HUD_crosshair_update(p_name, w_name, true)

  minetest.after(weapon.reload_time, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    p_meta:set_int("bl_weapon_state", 0)

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



function draw_particles(particle, dir, origin, range, pierce)
  local check_coll = not pierce

  minetest.add_particlespawner({
    amount = particle.amount,
    time = 0.3,   -- TODO: meglio funzione che approssima distanza? Time era 0.3, min/max erano impact_dist/(range * 1.5)
    pos = vector.new(origin),
    vel = vector.multiply(dir, range),
    size = 2,
    collisiondetection = check_coll,
    collision_removal = check_coll,
    texture = particle.image
  })
end