local S = minetest.get_translator("block_league")

local function reset_meta() end
local function init_dmg_table() end
local function create_and_show_HUD() end
local function remove_HUD() end
local function remove_spectate_HUD() end
local function equip() end
local function wait_for_respawn() end



arena_lib.on_load("block_league", function(arena)
  local players = arena.players

  for pl_name, stats in pairs(players) do
    reset_meta(pl_name)
    init_dmg_table(pl_name, players)
    equip(arena, pl_name)
    create_and_show_HUD(arena, pl_name)
    block_league.refill_weapons(arena, pl_name)

    stats.entering_time = arena.initial_time
  end

  minetest.after(0.1, function()
    block_league.info_panel_update_all(arena)
  end)

  block_league.HUD_show_inputs(arena)

  arena_lib.HUD_send_msg_all("broadcast", arena, S("The game will start soon"))
  block_league.countdown_and_start(arena, 3)
end)



arena_lib.on_start("block_league", function(arena)
  block_league.HUD_remove_inputs(arena)
  block_league.stamina_refill_loop(arena)
  block_league.fall_check_loop(arena)
end)



arena_lib.on_join("block_league", function(p_name, arena, as_spectator, was_spectator)
  if as_spectator then
    create_and_show_HUD(arena, p_name, true)
    minetest.after(0.1, function()
      block_league.HUD_scoreboard_update_score(arena)
    end)
    return
  end

  local players = arena.players

  players[p_name].entering_time = arena.current_time

  reset_meta(p_name)
  init_dmg_table(p_name, players, true)
  equip(arena, p_name)
  create_and_show_HUD(arena, p_name, false, was_spectator)
  block_league.HUD_spectate_addplayer(arena, p_name)
  block_league.refill_weapons(arena, p_name)

  minetest.sound_play("bl_voice_fight", {to_player = p_name})

  minetest.after(0.1, function()
    block_league.info_panel_update_all(arena)
    block_league.HUD_scoreboard_update_score(arena)
  end)
end)



arena_lib.on_celebration("block_league", function(arena, winners)
  arena.weapons_disabled = true

  for pl_name, pl_stats in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    block_league.deactivate_zoom(player)
    player:get_meta():set_int("bl_immunity", 1)

    panel_lib.get_panel(pl_name, "bl_info_panel"):show()
  end

  -- se è pareggio, passa una stringa (no one)
  local is_tie = type(winners) == "string" and true or false

  if not is_tie then
    for pl_name, pl_stats in pairs(arena.players) do
      if pl_stats.teamID == winners then
        minetest.sound_play("bl_jingle_victory", {to_player = pl_name})
      else
        minetest.sound_play("bl_jingle_defeat", {to_player = pl_name})
      end
    end

  else
    for pl_name, pl_stats in pairs(arena.players) do
      minetest.sound_play("bl_jingle_defeat", {to_player = pl_name})
    end
  end
end)



arena_lib.on_end("block_league", function(arena, players, winners, spectators)
  for sp_name, _ in pairs(spectators) do
    block_league.HUD_spectate_remove(players, sp_name)
    remove_HUD(sp_name, true)
    reset_meta(sp_name)
  end

  for pl_name, stats in pairs(players) do
    remove_HUD(pl_name)
    reset_meta(pl_name)
    block_league.deactivate_zoom(minetest.get_player_by_name(pl_name))
    pl_name:get_skill(block_league.get_player_skill(pl_name)):disable()

    --block_league.update_storage(pl_name)
  end
end)



arena_lib.on_death("block_league", function(arena, p_name, reason)
  local player = minetest.get_player_by_name(p_name)

  -- TD: se il giocatore è morto con la palla, questa si sgancia e torna a oscillare
  if arena.mode == 1 then
    for _, child in pairs (player:get_children()) do
      if child:get_luaentity() and child:get_luaentity().timer then
        local arena = arena_lib.get_arena_by_player(p_name)
        local ball = child:get_luaentity()

        if player:get_pos().y < arena.min_y then
          ball:reset()
        else
          ball:detach()
        end

        -- reindirizza sulla palla gli spettatori
        for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
          if arena.spectators[sp_name].was_following_ball then
            arena_lib.spectate_target("block_league", arena, sp_name, "entity", "Ball")
          end
        end
        break
      end
    end

  -- DM: se muoio suicida, perdo un'uccisione
  elseif arena.mode == 2 then
    local p_stats = arena.players[p_name]

    p_stats.kills = p_stats.kills - 1
    local team_id = p_stats.teamID
    local team = arena.teams[team_id]
    team.deaths = team.deaths + 1
    block_league.info_panel_update(arena, team_id)
  end

  local p_meta = player:get_meta()

  p_meta:set_int("bl_is_shooting", 0)
  p_meta:set_int("bl_death_delay", 1)

  block_league.deactivate_zoom(player)
  wait_for_respawn(arena, p_name, 6)
end)



arena_lib.on_respawn("block_league", function(arena, p_name)
  local player = minetest.get_player_by_name(p_name)

  -- se resuscita mentre non può ancora rientrare in partita, lo porto nella sala d'attesa
  if player:get_meta():get_int("bl_death_delay") == 1 then
    if arena.players[p_name].teamID == 1 then
      player:set_pos(arena.waiting_room_orange)
    else
      player:set_pos(arena.waiting_room_blue)
    end
  else
    block_league.HUD_spectate_update(arena, p_name, "alive")
  end

  arena.players[p_name].stamina = 100
  block_league.HUD_stamina_update(arena, p_name)
  block_league.refill_weapons(arena, p_name)
  player:set_physics_override({ speed = block_league.SPEED })
end)



arena_lib.on_change_spectated_target("block_league", function(arena, sp_name, t_type, t_name, prev_type, prev_spectated, is_forced)
  local sp_data = arena.spectators[sp_name]

  if t_type == "player" then
    if is_forced and prev_type == "entity" then
        sp_data.was_following_ball = true
    elseif not is_forced and sp_data.was_following_ball then
        sp_data.was_following_ball = false
    end

    -- ritardo di 0.1 perché on_join non è ancora stato chiamato, quindi non hanno ancora la HUD
    minetest.after(0.1, function()
      for _, weap_name in pairs(block_league.get_player_weapons(t_name)) do
        block_league.HUD_weapons_update(arena, t_name, weap_name)
      end
      block_league.HUD_skill_update(sp_name)
      block_league.HUD_stamina_update(arena, t_name)
    end)

  elseif t_type == "entity" then
    -- se al seguire la palla questa è in testa a qualcunə, segui quel qualcunə
    local parent = arena_lib.get_spectate_entities("block_league", arena.name)[t_name].object:get_attach()

    if not is_forced and not sp_data.was_following_ball and parent then
      arena_lib.spectate_target("block_league", arena, sp_name, "player", parent:get_player_name())
      sp_data.was_following_ball = true
    end

  elseif t_type == "area" then
    if is_forced and prev_type == "entity" then
        sp_data.was_following_ball = true
    elseif not is_forced and sp_data.was_following_ball then
        sp_data.was_following_ball = false
    end
  end
end)



arena_lib.on_quit("block_league", function(arena, p_name, is_spectator, reason)
  -- se non si è disconnesso, sgancia la palla e togli lo zoom. A quanto pare la
  -- palla non si sgancia da qua per chi si sconnette, prob get_player_name ritorna nullo
  if reason ~= 0 then
    if not is_spectator and arena.mode == 1 then
      local children = minetest.get_player_by_name(p_name):get_children()
      for _, child in pairs(children) do
        -- potrebbe essere essere un* spettator*, controllo che sia effettivamente la palla
        -- TEMP: get_luaentity() is needed for the moment, as entities on MT are
        -- half broken: they sometimes remain as an empty shell that can't be
        -- removed. If someone enters with a broken entity, we want to avoid the
        -- server go to kaboom (as their get_luaentity() returns nil)
        if not child:is_player() and child:get_luaentity() then
          child:get_luaentity():detach()
        end
      end
    end

    block_league.deactivate_zoom(minetest.get_player_by_name(p_name))
  end

  remove_spectate_HUD(arena, p_name, is_spectator)
  remove_HUD(p_name, is_spectator)
  reset_meta(p_name)
  p_name:get_skill(block_league.get_player_skill(p_name)):disable()

  block_league.info_panel_update_all(arena)
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function reset_meta(p_name)
  local p_meta = minetest.get_player_by_name(p_name):get_meta()

  p_meta:set_int("bl_has_ball", 0)
  p_meta:set_int("bl_weap_delay", 0)
  p_meta:set_int("bl_bouncer_delay", 0)
  p_meta:set_int("bl_death_delay", 0)
  p_meta:set_int("bl_immunity", 0)
  p_meta:set_int("bl_reloading", 0)
  p_meta:set_int("bl_is_shooting", 0)
end



function init_dmg_table(p_name, players, in_progress)
  local dmg_table = players[p_name].dmg_received
  -- potrebbero esserci armi con fuoco amico, metti qualsiasi giocatorə
  for pl_name, _ in pairs(players) do
    dmg_table[pl_name] = {timestamp = 99999, dmg = 0}
  end

  -- se in corso, aggiungo nuovə giocatorə per chi era già dentro
  if in_progress then
    for pl_name, pl_data in pairs(players) do
      pl_data.dmg_received[p_name] = {timestamp = 99999, dmg = 0}
    end
  end
end



function create_and_show_HUD(arena, p_name, is_spectator, was_spectator)
  -- se stava già seguendo come spettatorə
  if was_spectator then
    panel_lib.get_panel(p_name, "bl_weapons"):remove()
    panel_lib.get_panel(p_name, "bl_skill"):remove()
    block_league.HUD_spectate_remove(arena.players, p_name)

    local team_marker = arena.players[p_name].teamID == 1 and "bl_hud_scoreboard_orangemark.png" or "bl_hud_scoreboard_bluemark.png"
    panel_lib.get_panel(p_name, "bl_scoreboard"):update(nil, nil, {team_marker = {text = team_marker}})
    block_league.HUD_stamina_update(arena, p_name)

  -- se entra per la prima volta
  else
    block_league.HUD_broadcast_create(p_name)
    block_league.HUD_stamina_create(arena, p_name)
    block_league.HUD_scoreboard_create(arena, p_name, is_spectator)
    block_league.HUD_log_create(p_name)

    minetest.get_player_by_name(p_name):hud_set_flags({crosshair = false})
  end

  block_league.HUD_critical_create(p_name) -- TODO: abbastanza sicuro che questo non debba essere generato ogni volta
  block_league.HUD_weapons_create(p_name)
  block_league.HUD_skill_create(p_name)

  if is_spectator then
    block_league.HUD_spectate_create(arena, p_name)
  else
    block_league.info_panel_create(arena, p_name)
  end
end



function remove_HUD(p_name, is_spectator)
  block_league.HUD_critical_remove(p_name)
  panel_lib.get_panel(p_name, "bl_stamina"):remove()
  panel_lib.get_panel(p_name, "bl_weapons"):remove()
  panel_lib.get_panel(p_name, "bl_crosshair"):remove()
  panel_lib.get_panel(p_name, "bl_skill"):remove()
  panel_lib.get_panel(p_name, "bl_broadcast"):remove()
  panel_lib.get_panel(p_name, "bl_scoreboard"):remove()
  panel_lib.get_panel(p_name, "bl_log"):remove()

  minetest.get_player_by_name(p_name):hud_set_flags({crosshair = true})

  if is_spectator then return end

  arena_lib.HUD_hide("all", p_name)
  panel_lib.get_panel(p_name, "bl_info_panel"):remove()
  block_league.HUD_remove_inputs(p_name)
end



function remove_spectate_HUD(arena, p_name, is_spectator)
  if is_spectator then
    block_league.HUD_spectate_remove(arena.players, p_name)
  else
    block_league.HUD_spectate_removeplayer(arena, p_name)
  end
end



function equip(arena, p_name)
  local weapons = block_league.get_player_weapons(p_name)
  local bouncer = arena.mode == 1 and "block_league:bouncer" or "block_league:bouncer_dm"
  local inv = minetest.get_player_by_name(p_name):get_inventory()

  for i, weapon_name in pairs(weapons) do
    inv:add_item("main", ItemStack(weapon_name))
  end
  inv:add_item("main", ItemStack(bouncer))

  local skill = block_league.get_player_skill(p_name)

  p_name:get_skill(skill):enable()
end



function wait_for_respawn(arena, p_name, time_left)

  if not arena_lib.is_player_in_arena(p_name, "block_league") or arena.weapons_disabled then
    arena_lib.HUD_hide("broadcast", p_name)
  return end

  if time_left > 0 then
    arena_lib.HUD_send_msg("broadcast", p_name, S("Back in the game in @1", time_left))
  else
    local player = minetest.get_player_by_name(p_name)

    player:get_meta():set_int("bl_death_delay", 0)
    player:get_meta():set_int("bl_reloading", 0)
    arena_lib.HUD_hide("broadcast", p_name)

    -- se è nella sala d'attesa
    if player:get_hp() > 0 then
      block_league.HUD_spectate_update(arena, p_name, "alive")
      player:set_pos(arena_lib.get_random_spawner(arena, arena.players[p_name].teamID))
      block_league.immunity(player)
    end

    return
  end

  time_left = time_left -1

  minetest.after(1, function()
    wait_for_respawn(arena, p_name, time_left)
  end)
end
