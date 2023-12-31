local S = minetest.get_translator("block_league")

local function exit_test_mode() end

local players_in_test_mode = {}
local items = {
  "block_league:bouncer",
  "",
  "",
  "",
  "",
  "",
  "",
  "block_league:testkit_quit",
}



minetest.register_tool("block_league:testkit_quit", {

    description = S("Leave test mode"),
    inventory_image = "bl_testkit_quit.png",
    groups = {not_in_creative_inventory = 1, oddly_breakable_by_hand = "2"},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      exit_test_mode(itemstack, user)
    end

})



function block_league.enter_test_mode(sender)

  if players_in_test_mode[sender] then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("You already are in test mode!")))
    return end

  local player = minetest.get_player_by_name(sender)
  local inv = player:get_inventory()

  players_in_test_mode[sender] = {inv = inv:get_list("main"), physics = player:get_physics_override()}
  inv:set_list("main", items)
  player:set_physics_override(block_league.PHYSICS)

  local meta = player:get_meta()

  meta:set_int("bl_bouncer_delay", 0)
  meta:set_int("bl_death_delay", 0)
  meta:set_int("bl_weapon_state", 0)
  meta:set_int("bl_is_speed_locked", 0)

  minetest.chat_send_player(sender, "[Block League] " .. S("You've entered test mode"))
end



function exit_test_mode(itemstack, user)

  local p_name = user:get_player_name()

  user:set_physics_override(players_in_test_mode[p_name].physics)
  local old_inv = players_in_test_mode[p_name].inv

  players_in_test_mode[p_name] = nil
  minetest.chat_send_player(p_name, "[Block League] " .. S("You've left test mode"))

  minetest.after(0, function()
    user:get_inventory():set_list("main", old_inv)
  end)

end
