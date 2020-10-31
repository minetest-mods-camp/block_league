function block_league.energy_create(arena, p_name)

  local p_energy = arena.players[p_name].energy

  Panel:new({
    name = "bl_energy",
    player = p_name,
    bg = "",
    title = "",
    position = { x = 0.5, y = 1 },
    alignment = { x = -1, y = 0 },
    sub_img_elems = {
      energy_indicator = {
        scale = {x = p_energy/6.5, y = 1.3},
        offset = {x = 20, y = -78},
        alignment = { x = 1, y = 0 },
        text = "bl_hud_energy.png"
      },
    }

  })
end


function block_league.energy_update(arena, p_name)

  local panel = panel_lib.get_panel(p_name, "bl_energy")

  panel:update(nil,
    {energy_indicator = {
      scale = {x = arena.players[p_name].energy/6.5, y = 1.2},
    }}
  )

end
