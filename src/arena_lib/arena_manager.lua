local S = minetest.get_translator("block_league")

local function reset_meta() end
local function create_and_show_HUD() end
local function remove_HUD() end
local function remove_spectate_HUD() end
local function equip_weapons() end
local function wait_for_respawn() end



arena_lib.on_load("block_league", function(arena)

  for pl_name, stats in pairs(arena.players) do
    reset_meta(pl_name)
    equip_weapons(arena, pl_name)
    create_and_show_HUD(arena, pl_name)
    block_league.refill_weapons(arena, pl_name)

    stats.entering_time = arena.initial_time
  end

  minetest.after(0.1, function()
    block_league.info_panel_update(arena)
  end)

  block_league.HUD_show_inputs(arena)

  arena_lib.HUD_send_msg_all("broadcast", arena, S("The game will start soon"))
  block_league.countdown_and_start(arena, 3)
end)



arena_lib.on_start("block_league", function(arena)
  block_league.HUD_remove_inputs(arena)
  block_league.energy_refill_loop(arena)
  block_league.fall_check_loop(arena)
end)



arena_lib.on_join("block_league", function(p_name, arena, as_spectator)

  if as_spectator then
    create_and_show_HUD(arena, p_name, true)
    minetest.after(0.1, function()
      block_league.scoreboard_update_score(arena)
    end)
    return
  end

  arena.players[p_name].entering_time = arena.current_time

  reset_meta(p_name)
  equip_weapons(arena, p_name)
  create_and_show_HUD(arena, p_name)
  block_league.HUD_spectate_addplayer(arena, p_name)
  block_league.refill_weapons(arena, p_name)

  minetest.sound_play("bl_voice_fight", {to_player = p_name})

  minetest.after(0.1, function()
    block_league.info_panel_update(arena)
    block_league.scoreboard_update_score(arena)
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

    block_league.update_storage(pl_name)
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
        break
      end
    end

  -- DM: se muoio suicida, perdo un'uccisione
  elseif arena.mode == 2 then
    local p_stats = arena.players[p_name]

    p_stats.kills = p_stats.kills - 1
    local team = arena.teams[p_stats.teamID]
    team.deaths = team.deaths + 1
    block_league.info_panel_update(arena)
  end

  block_league.deactivate_zoom(player)
  player:get_meta():set_int("bl_death_delay", 1)

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

  arena.players[p_name].energy = 100
  block_league.HUD_energy_update(arena, p_name)
  block_league.refill_weapons(arena, p_name)
  player:set_physics_override({ speed = block_league.SPEED })
end)



arena_lib.on_change_spectated_target("block_league", function(arena, sp_name, t_type, t_name, prev_type, prev_spectated)
  if t_type ~= "player" then return end
  -- ritardo di 0.1 perché on_join non è ancora stato chiamato, quindi non hanno ancora la HUD
  minetest.after(0.1, function()
    for _, weap_name in pairs(block_league.get_player_weapons(t_name)) do
      block_league.HUD_weapons_update(arena, t_name, weap_name)
    end
    block_league.HUD_energy_update(arena, t_name)
  end)
end)



arena_lib.on_quit("block_league", function(arena, p_name, is_spectator, reason)

  -- se non si è disconnesso, sgancia la palla e togli lo zoom. A quanto pare la
  -- palla non si sgancia da qua per chi si sconnette, prob get_player_name ritorna nullo
  if reason ~= 0 then
    if not is_spectator and arena.mode == 1 then
      if minetest.get_player_by_name(p_name):get_children()[1] then
        local ball = minetest.get_player_by_name(p_name):get_children()[1]:get_luaentity()
        ball:detach()
      end
    end

    block_league.deactivate_zoom(minetest.get_player_by_name(p_name))
  end

  remove_spectate_HUD(arena, p_name, is_spectator)
  remove_HUD(p_name, is_spectator)
  reset_meta(p_name)

  block_league.info_panel_update(arena)
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function reset_meta(p_name)
  local p_meta = minetest.get_player_by_name(p_name):get_meta()

  p_meta:set_int("bl_has_ball", 0)
  p_meta:set_int("bl_weap_delay", 0)
  p_meta:set_int("bl_weap_secondary_delay", 0)
  p_meta:set_int("bl_bouncer_delay", 0)
  p_meta:set_int("bl_death_delay", 0)
  p_meta:set_int("bl_immunity", 0)
  p_meta:set_int("bl_reloading", 0)
end



function create_and_show_HUD(arena, p_name, is_spectator)
  block_league.HUD_broadcast_create(p_name)
  block_league.HUD_critical_create(p_name)
  block_league.HUD_energy_create(arena, p_name)
  block_league.HUD_weapons_create(p_name)
  block_league.scoreboard_create(arena, p_name)
  block_league.hud_log_create(p_name)

  if is_spectator then
    block_league.HUD_spectate_create(arena, p_name)
    return
  end

  block_league.info_panel_create(arena, p_name)
end



function remove_HUD(p_name, is_spectator)
  block_league.HUD_critical_remove(p_name)
  panel_lib.get_panel(p_name, "bl_energy"):remove()
  panel_lib.get_panel(p_name, "bl_weapons"):remove()
  panel_lib.get_panel(p_name, "bl_broadcast"):remove()
  panel_lib.get_panel(p_name, "bl_scoreboard"):remove()
  panel_lib.get_panel(p_name, "bl_log"):remove()

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



function equip_weapons(arena, p_name)

  local weapons = block_league.get_player_weapons(p_name)
  local bouncer = arena.mode == 1 and "block_league:bouncer" or "block_league:bouncer_dm"
  local inv = minetest.get_player_by_name(p_name):get_inventory()

  for i, weapon_name in pairs(weapons) do
    inv:add_item("main", ItemStack(weapon_name))
  end
  inv:add_item("main", ItemStack(bouncer))
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
