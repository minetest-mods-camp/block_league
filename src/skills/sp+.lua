local S = minetest.get_translator("block_league")

-- there is no "+" in the registration name as it causes issues when retrieving images names
skillz.register_skill("block_league:sp", {
  name = "SP+",
  description = "Increases your stamina by 25",
  profile_description = S("Increases your stamina points by 25 @1(100>125)", "<style color=#abc0c0>") .. "</style>\n\n"
    .. S("Great choice for strikers, as it allows players to run more and perform tricks more often."),
  passive = true,
  on_start = function(self)
    local p_name = self.pl_name
    local arena = arena_lib.get_arena_by_player(p_name)

    if not arena then return end

    arena.players[p_name].energy_max = 125
  end
})
