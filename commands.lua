S = minetest.get_translator("block_league")

local mod = "block_league"

ChatCmdBuilder.new("bleagueadmin", function(cmd)

    -- creazione arene
    cmd:sub("create :arena :tipologia:int", function(sender, arena_name, tipologia)
        arena_lib.create_arena(sender, mod, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "mod" , tipologia)
    end)

    cmd:sub("create :arena :minplayers:int :maxplayers:int :tipologia:int", function(sender, arena_name, min_players, max_players, tipologia)
        arena_lib.create_arena(sender, mod, arena_name, min_players, max_players)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "mod" , tipologia)
    end)

    cmd:sub("create :arena :minplayers:int :maxplayers:int :scorecap:int :tipologia:int", function(sender, arena_name, min_players, max_players, score_cap, tipologia)
        arena_lib.create_arena(sender, mod, arena_name, min_players, max_players)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "mod" , tipologia)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "score_cap" , score_cap)
    end)

    -- rimozione arene
    cmd:sub("remove :arena", function(sender, arena_name)
        arena_lib.remove_arena(sender, mod, arena_name)
    end)

    -- rinominazione arene
    cmd:sub("rename :arena :newname", function(sender, arena_name, new_name)
        arena_lib.rename_arena(sender, mod, arena_name, new_name)
    end)

    --
   cmd:sub("properties :arena :property :newvalue:text", function(sender, arena_name, property, new_value)
       arena_lib.change_arena_properties(sender, mod, arena_name, property, new_value)
       end)

    -- cambio giocatori minimi/massimi
    cmd:sub("setplayers :arena :minplayers:int :maxplayers:int", function(sender, arena_name, min_players, max_players)
        arena_lib.change_players_amount(sender, mod, arena_name, min_players, max_players)
    end)

    -- abilitazione/disabilitazione team per arena (enable 0 o 1)
    cmd:sub("toggleteams :arena :enable:int", function(sender, arena_name, enable)
        arena_lib.toggle_teams_per_arena(sender, mod, arena_name, enable)
    end)

    -- lista arene
    cmd:sub("list", function(sender)
        arena_lib.print_arenas(sender, mod)
    end)

    -- info su un'arena specifica
    cmd:sub("info :arena", function(sender, arena_name)
        arena_lib.print_arena_info(sender, mod, arena_name)
    end)

    -- info su stats partita
    cmd:sub("score :arena", function(sender, arena_name)
        arena_lib.print_arena_stats(sender, mod, arena_name)
    end)


    -- modifiche arena
    --editor
    cmd:sub("edit :arena", function(sender, arena)
        arena_lib.enter_editor(sender, mod, arena)
    end)

    --inline
    -- cartello arena
    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, mod, arena)
    end)

    -- spawner (ie. deleteall)
    cmd:sub("setspawn :arena :param:word :ID:int", function(sender, arena, param, ID)
        arena_lib.set_spawner(sender, mod, arena, nil, param, ID)
    end)

    -- spawner (ie. deleteall)
    cmd:sub("setspawn :arena :team:word :param:word :ID:int", function(sender, arena, team_name, param, ID)
        arena_lib.set_spawner(sender, mod, arena, team_name, param, ID)
    end)

    cmd:sub("setspawn :arena", function(sender, arena)
        arena_lib.set_spawner(sender, mod, arena)
    end)

    -- teletrasporto
    cmd:sub("tp :arena", function(sender, arena)
      arena_lib.teleport_in_arena(sender, mod, arena)
    end)

    -- abilitazione e disabilitazione arene
    cmd:sub("enable :arena", function(sender, arena)
        arena_lib.enable_arena(sender, mod, arena)
    end)

    cmd:sub("disable :arena", function(sender, arena)
        arena_lib.disable_arena(sender, mod, arena)
    end)

    -- aggiunta/rimozione TD. option può essere "add" o "remove"
    cmd:sub("goal :option :arena :team", function(sender, option, arena_name, team)
      -- TODO: muovere in una funzione a parte
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)

        if not arena then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if arena.mod == 2 then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if team ~= "red" and team ~= "blue" then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        local team_goal = team == "red" and "goal_red" or "goal_blue"

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

    cmd:sub("ball :option :arena", function(sender, option, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)

        if not arena then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if arena.mod == 2 then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        if option ~= "set" and option ~= "remove" then
          minetest.chat_send_player(sender, "Invalid parameter")
          return end

        local new_param = option == "set" and vector.round(minetest.get_player_by_name(sender):get_pos()) or {}

        arena_lib.change_arena_property(sender, "block_league", arena_name, "ball_spawn" , new_param)
    end)

    cmd:sub("addminy :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
        arena_lib.change_arena_property(sender, "block_league", arena_name, "min_y" , pos.y)
    end)

    cmd:sub("removeminy :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "min_y" , 0)
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
