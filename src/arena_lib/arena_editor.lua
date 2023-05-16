local S = minetest.get_translator("block_league")

local function show_waypoints() end
local function remove_waypoints() end
local function give_items() end

local waypoints = {} -- KEY: player name; VALUE: {waypoints IDs}


arena_lib.on_join_editor("block_league", function(p_name, arena)
  show_waypoints(p_name, arena)
end)



arena_lib.on_leave_editor("block_league", function(p_name, arena)
  remove_waypoints(p_name, arena)
end)



arena_lib.register_editor_section("block_league", {
  name = S("Mode, waiting rooms and more"),
  icon = "bl_editor.png",
  give_items = function(itemstack, user, arena) return give_items(user, arena) end
})





minetest.register_tool("block_league:editor_mode", {

    description = S("Change mode (LMB TD, RMB DM)"),
    inventory_image = "bl_editor_mode.png",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)

      if arena.mode == 1 then return end

      arena_lib.change_arena_property(user:get_player_name(), mod, arena_name, "mode", 1, true)
      user:get_inventory():set_stack("main", 3, "block_league:editor_goal")
      user:get_inventory():set_stack("main", 4, "block_league:editor_ball")
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)

      if arena.mode == 2 then return end

      local p_name      = user:get_player_name()
      local p_inv       = user:get_inventory()

      arena.ball_spawn = {}
      arena.goal_orange = {}
      arena.goal_blue = {}
      arena_lib.change_arena_property(p_name, mod, arena_name, "mode", 2, true) -- salva anche i parametri precedenti, hehe
      p_inv:set_stack("main", 3, {})
      p_inv:set_stack("main", 4, {})
      show_waypoints(p_name, arena)
    end,

    on_place = function(itemstack, placer, pointed_thing)
      local mod         = placer:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = placer:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)

      if arena.mode == 2 then return end

      local p_name      = placer:get_player_name()
      local p_inv       = placer:get_inventory()

      arena.ball_spawn = {}
      arena.goal_orange = {}
      arena.goal_blue = {}
      arena_lib.change_arena_property(p_name, mod, arena_name, "mode", 2, true) -- salva anche i parametri precedenti, hehe
      p_inv:set_stack("main", 3, {})
      p_inv:set_stack("main", 4, {})
      show_waypoints(p_name, arena)
    end
})



minetest.register_tool("block_league:editor_wroom", {

    description = S("Set waiting room (LMB orange, RMB blue)"),
    inventory_image = "bl_editor_wroom.png",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "waiting_room_orange", user:get_pos(), true)
      show_waypoints(p_name, arena)
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "waiting_room_blue", user:get_pos(), true)
      show_waypoints(p_name, arena)
    end,

    on_place = function(itemstack, placer, pointed_thing)
      local mod         = placer:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = placer:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = placer:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "waiting_room_blue", placer:get_pos(), true)
      show_waypoints(p_name, arena)
    end
})



minetest.register_tool("block_league:editor_goal", {

    description = S("Set team goal (LMB orange, RMB blue)"),
    inventory_image = "bl_editor_goal.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "goal_orange", user:get_pos(), true)
      show_waypoints(p_name, arena)
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "goal_blue", user:get_pos(), true)
      show_waypoints(p_name, arena)
    end,

    on_place = function(itemstack, placer, pointed_thing)
      local mod         = placer:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = placer:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = placer:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "goal_blue", placer:get_pos(), true)
      show_waypoints(p_name, arena)
    end
})



minetest.register_tool("block_league:editor_ball", {

    description = S("Set ball spawn point"),
    inventory_image = "bl_editor_ball.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      arena_lib.change_arena_property(p_name, mod, arena_name, "ball_spawn", user:get_pos(), true)
      show_waypoints(p_name, arena)
    end
})



minetest.register_tool("block_league:editor_death", {

    description = S("Set minimum Y (death below)"),
    inventory_image = "bl_editor_death.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")

      arena_lib.change_arena_property(user:get_player_name(), mod, arena_name, "min_y", user:get_pos().y, true)
    end
})




----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function show_waypoints(p_name, arena)
  -- se sto aggiornando, devo prima rimuovere i vecchi
  if waypoints[p_name] then
    remove_waypoints(p_name)
  end

  local player = minetest.get_player_by_name(p_name)
  waypoints[p_name] = {}

  minetest.after(0.1, function()
    if next(arena.ball_spawn) then
      local HUD_ID = player:hud_add({
        hud_elem_type = "image_waypoint",
        text = "bl_editor_waypoint_ball.png",
        world_pos = arena.ball_spawn,
        scale = {x = 5, y = 5}
      })

      table.insert(waypoints[p_name], HUD_ID)
    end

    if next(arena.waiting_room_orange) then
      local HUD_ID = player:hud_add({
        hud_elem_type = "image_waypoint",
        text = "bl_editor_waypoint_wroom_orange.png",
        world_pos = arena.waiting_room_orange,
        scale = {x = 5, y = 5}
      })

      table.insert(waypoints[p_name], HUD_ID)
    end

    if next(arena.waiting_room_blue) then
      local HUD_ID = player:hud_add({
        hud_elem_type = "image_waypoint",
        text = "bl_editor_waypoint_wroom_blue.png",
        world_pos = arena.waiting_room_blue,
        scale = {x = 5, y = 5}
      })

      table.insert(waypoints[p_name], HUD_ID)
    end

    if next(arena.goal_orange) then
      local HUD_ID = player:hud_add({
        hud_elem_type = "image_waypoint",
        text = "bl_editor_waypoint_goal_orange.png",
        world_pos = arena.goal_orange,
        scale = {x = 5, y = 5}
      })

      table.insert(waypoints[p_name], HUD_ID)
    end

    if next(arena.goal_blue) then
      local HUD_ID = player:hud_add({
        hud_elem_type = "image_waypoint",
        text = "bl_editor_waypoint_goal_blue.png",
        world_pos = arena.goal_blue,
        scale = {x = 5, y = 5}
      })

      table.insert(waypoints[p_name], HUD_ID)
    end
  end)
end



function remove_waypoints(p_name, arena)
  local player = minetest.get_player_by_name(p_name)
  -- potrebbe essersi disconnesso. Evito di computare in caso
  if player then
    for _, waypoint_ID in pairs(waypoints[p_name]) do
      player:hud_remove(waypoint_ID)
    end
  end

  waypoints[p_name] = nil
end



function give_items(user, arena)
  local items = {
    "block_league:editor_mode",
    "block_league:editor_wroom",
    "",
    "",
    "block_league:editor_death"
  }

  if arena.mode == 1 then
    items[3] = "block_league:editor_goal"
    items[4] = "block_league:editor_ball"
  end

  return items
end
