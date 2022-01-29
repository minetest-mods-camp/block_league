function block_league.HUD_energy_create(arena, p_name)

  Panel:new("bl_energy", {
    player = p_name,
    bg = "bl_hud_energy_empty.png",
    title = "",
    position = { x = 0.5, y = 1 },
    alignment = { x = 1, y = 0 },
    offset = { x = 20, y = -76},
    bg_scale = { x = 1.5, y = 1.5},
    sub_img_elems = {
      energy_indicator = {
        offset = { x = 5 },
        text = "bl_hud_energy.png"
      },
    }

  })
end


function block_league.HUD_energy_update(arena, p_name)

  local energy = arena.players[p_name].energy
  local panel = panel_lib.get_panel(p_name, "bl_energy")

  panel:update(nil,
    {energy_indicator = {
      scale = {x = (energy / 100) * 1.5, y = 1.5},
    }}
  )

  for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
    local panel = panel_lib.get_panel(sp_name, "bl_energy")

    panel:update(nil,
      {energy_indicator = {
        scale = {x = (energy / 100) * 1.5, y = 1.5},
      }}
    )
  end
end
