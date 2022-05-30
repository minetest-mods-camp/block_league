S = minetest.get_translator("block_league")

local mod = "block_league"

ChatCmdBuilder.new("bladmin", function(cmd)

    -- creazione arene
    cmd:sub("create :arena :mode:int", function(sender, arena_name, mode)
        arena_lib.create_arena(sender, mod, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "mode" , mode)
    end)

    -- rimozione arene
    cmd:sub("remove :arena", function(sender, arena_name)
        arena_lib.remove_arena(sender, mod, arena_name)
    end)

    -- rinominazione arene
    cmd:sub("rename :arena :newname", function(sender, arena_name, new_name)
        arena_lib.rename_arena(sender, mod, arena_name, new_name)
    end)

    -- lista arene
    cmd:sub("list", function(sender)
        arena_lib.print_arenas(sender, mod)
    end)

    -- info su un'arena specifica
    cmd:sub("info :arena", function(sender, arena_name)
        arena_lib.print_arena_info(sender, mod, arena_name)
    end)

    --editor
    cmd:sub("edit :arena", function(sender, arena)
        arena_lib.enter_editor(sender, mod, arena)
    end)

    -- cartello arena
    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, mod, arena)
    end)

    -- abilitazione e disabilitazione arene
    cmd:sub("enable :arena", function(sender, arena)
        arena_lib.enable_arena(sender, mod, arena)
    end)

    cmd:sub("disable :arena", function(sender, arena)
        arena_lib.disable_arena(sender, mod, arena)
    end)

    -- aggiunta/rimozione TD. option può essere "set" o "remove"
    cmd:sub("goal :option :arena :team", function(sender, option, arena_name, team)
      -- TODO: muovere in una funzione a parte
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)

        if not arena then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if arena.mode ~= 1 then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if team ~= "orange" and team ~= "blue" then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        local team_goal = team == "orange" and "goal_orange" or "goal_blue"

        if option == "set" then
          local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
          arena_lib.change_arena_property(sender, "block_league", arena_name, team_goal, pos)
        elseif option == "remove" then
          arena_lib.change_arena_property(sender, "block_league", arena_name, team_goal , {})
        else
          minetest.chat_send_player(sender, "Invalid parameter")
          return
        end
    end)

    -- aggiunta/rimozione palla. option può essere "set" o "remove"
    cmd:sub("ball :option :arena", function(sender, option, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)

        if not arena then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if arena.mode == 2 then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if option ~= "set" and option ~= "remove" then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        local new_param = option == "set" and vector.round(minetest.get_player_by_name(sender):get_pos()) or {}

        arena_lib.change_arena_property(sender, "block_league", arena_name, "ball_spawn" , new_param)
    end)

    -- aggiunta/rimozione sala d'attesa. option può essere "set" o "remove"
    cmd:sub("wroom :option :arena :team", function(sender, option, arena_name, team)

      local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)

      if not arena then
        minetest.chat_send_player(sender, "Invalid parameter")
        return end

      if arena.mode ~= 1 and arena.mode ~= 2 then
        minetest.chat_send_player(sender, "Invalid parameter")
        return end

      if team ~= "orange" and team ~= "blue" then
        minetest.chat_send_player(sender, "Invalid parameter")
        return end

      local w_room = team == "orange" and "waiting_room_orange" or "waiting_room_blue"

      if option == "set" then
        local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
        arena_lib.change_arena_property(sender, "block_league", arena_name, w_room, pos)
      elseif option == "remove" then
        arena_lib.change_arena_property(sender, "block_league", arena_name, w_room , {})
      else
        minetest.chat_send_player(sender, "Invalid parameter")
        return
      end
    end)

    cmd:sub("testkit", function(sender)
      block_league.enter_test_mode(sender)
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

end,{})
