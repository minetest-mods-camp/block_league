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

    cmd:sub("adddestination :arena :team", function(sender, arena_name, team)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
        if team == "red" then
          arena_lib.change_arena_property(sender, "block_league", arena_name, "destinazione_red" , pos)
          print("Aggiunta destinazione red")
        else
          arena_lib.change_arena_property(sender, "block_league", arena_name, "destinazione_blue" , pos)
          print("Aggiunta destinazione blue")
        end

    end)

    --Rimuove la destinazione.
    cmd:sub("removedestination :arena :team", function(sender, arena_name, team)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        if team == "red" then
          arena_lib.change_arena_property(sender, "block_league", arena_name, "destinazione_red" , {})
          print("Rimossa destinazione red")
        else
          arena_lib.change_arena_property(sender, "block_league", arena_name, "destinazione_blue" , {})
          print("Rimossa destinazione blue")
        end

    end)

    cmd:sub("addspawn :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
        arena_lib.change_arena_property(sender, "block_league", arena_name, "prototipo_spawn" , pos)
        print("Aggiunto spawn")

    end)

    cmd:sub("removespawn :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "prototipo_spawn" , {})
        print("Rimosso spawn")
    end)

    cmd:sub("addminy :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
        arena_lib.change_arena_property(sender, "block_league", arena_name, "min_y" , pos.y)
        print("Aggiunta y minima")

    end)

    cmd:sub("removeminy :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("block_league", arena_name)
        arena_lib.change_arena_property(sender, "block_league", arena_name, "min_y" , 0)
        print("Rimossa y minima")
    end)


end, {
  description = S("mod management"),
  privs = { block_league_admin = true }
})




ChatCmdBuilder.new("bleague", function(cmd)
  cmd:sub("achievements", function(sender)
    block_league.list_achievements(sender)
  end)

  cmd:sub("achievements :playername", function(sender, p_name)
    block_league.list_achievements(sender, p_name)
  end)

end,{})
