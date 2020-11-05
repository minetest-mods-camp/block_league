function block_league.immunity(player)

  local p_name = player:get_player_name()
  local immunity_time = arena_lib.get_arena_by_player(p_name).immunity_time
  local immunity_ID = 0

  player:set_armor_groups({immortal=1})

  -- in caso uno spari, perda l'immunità, muoia subito e resusciti, il tempo d'immunità riparte da capo.
  -- Ne tengo traccia con un metadato che comparo nell'after
  immunity_ID = player:get_meta():get_int("bl_immunity_ID") + 1
  player:get_meta():set_int("bl_immunity_ID", immunity_ID)

  minetest.after(immunity_time, function()
    if not arena_lib.is_player_in_arena(p_name, "block_league") then return end
    if immunity_ID == player:get_meta():get_int("bl_immunity_ID") then
      if player:get_armor_groups().immortal and player:get_armor_groups().immortal == 1 then
        player:set_armor_groups({immortal = nil})
      end
      player:get_meta():set_int("bl_immunity_ID", 0)
    end
  end)

end
