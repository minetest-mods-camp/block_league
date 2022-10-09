function block_league.HUD_stamina_create(arena, p_name)

  Panel:new("bl_stamina", {
    player = p_name,
    bg = "bl_hud_stamina_empty.png",
    title = "",
    position = { x = 0.5, y = 1 },
    alignment = { x = 1, y = 0 },
    offset = { x = 20, y = -76},
    bg_scale = { x = 1.5, y = 1.5},
    sub_img_elems = {
      stamina_indicator = {
        offset = { x = 5 },
        text = "bl_hud_stamina.png"
      },
    }

  })
end


function block_league.HUD_stamina_update(arena, p_name)

  local stamina = arena.players[p_name].stamina
  local stamina_max = arena.players[p_name].stamina_max
  local panel = panel_lib.get_panel(p_name, "bl_stamina")

  panel:update(nil,
    {stamina_indicator = {
      scale = {x = (stamina / stamina_max) * 1.5, y = 1.5},
    }}
  )

  for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
    local panel = panel_lib.get_panel(sp_name, "bl_stamina")

    panel:update(nil,
      {stamina_indicator = {
        scale = {x = (stamina / stamina_max) * 1.5, y = 1.5},
      }}
    )
  end
end
