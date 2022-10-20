local S = minetest.get_translator("block_league")

-- there is no "+" in the registration name as it causes issues when retrieving images names
skillz.register_skill("block_league:hp", {
  name = "HP+",
  icon = "bl_skill_hp.png",
  profile_description = S("Increases your health points by 5 @1(20>25)", "<style color=#abc0c0>") .. "</style>\n\n"
    .. S("Great for remaining in action longer, providing firepower to sustain your team. Get tanky!"),
  passive = true,
  on_start = function(self)
    local player = self.player
    player:set_properties({hp_max = 25})
    player:set_hp(25)
  end,
  on_stop = function(self)
    self.player:get_properties().hp_max = minetest.PLAYER_MAX_HP_DEFAULT
  end
})
