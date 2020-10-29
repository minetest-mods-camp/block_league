function block_league.energy_create(arena, p_name)

  local p_energy = arena.players[p_name].energy

  Panel:new({
    name = "bl_energy",
    player = p_name,
    bg = "",
    title = "",
    position = { x = 0.5, y = 1 },
    alignment = { x = 0, y = 0 },
    sub_img_elems = {
      energy_indicator = {
        scale = {x = p_energy/5, y = 1.7},
        offset = {x = 0, y = -110},
        alignment = { x = 0, y = 0 },
        text = "block_league_hud_panel_playerindicator.png"
      },
    },
    sub_txt_elems = {
      energy_clmn = {
        alignment = { x = 0, y = 1 },
        offset = {x = 0, y = -118},
        text = p_energy
      },
    }

  })
end


function block_league.energy_update(arena, p_name)

  local panel = panel_lib.get_panel(p_name, "bl_energy")

  panel:update(nil,
    {energy_clmn = {
      text = arena.players[p_name].energy
    }}
  )
  panel:update(nil,
    {energy_indicator = {
      scale = {x = arena.players[p_name].energy/5, y = 1.7},
    }}
  )


end
