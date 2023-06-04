local S = minetest.get_translator("block_league")

local mod = "block_league"



ChatCmdBuilder.new("bladmin", function(cmd)
    -- rinominazione arene
    cmd:sub("rename :arena :newname", function(sender, arena_name, new_name)
        arena_lib.rename_arena(sender, mod, arena_name, new_name)
    end)

    cmd:sub("testkit", function(sender)
      block_league.enter_test_mode(sender)
    end)

    -- need it to allow command blocks to run /bladmin @nearest, or I don't know how to open players' profiles through pressure plates and the like
    cmd:sub("profile :playername", function(sender, p_name)
      if arena_lib.is_player_in_arena(sender) or not minetest.get_player_by_name(p_name) then
        minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] You can't perform this action right now!")))
        return end

      block_league.show_profile(p_name)
    end)

end, {
  description = S("mod management"),
  privs = { blockleague_admin = true }
})




ChatCmdBuilder.new("bleague", function(cmd)
  cmd:sub("achievements", function(sender)
    block_league.list_achievements(sender)
  end)

  cmd:sub("achievements :playername", function(sender, p_name)
    block_league.list_achievements(sender, p_name)
  end)

  cmd:sub("profile", function(sender)
    if arena_lib.is_player_in_arena(sender) then
      minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] You can't perform this action right now!")))
      return end

    block_league.show_profile(sender)
  end)
end,{})
