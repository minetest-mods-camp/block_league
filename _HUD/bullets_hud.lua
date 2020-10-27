local S = minetest.get_translator("block_league")

function block_league.weapons_hud_create(p_name)

  local inv = minetest.get_player_by_name(p_name):get_inventory()
  local sub_img_elems = {}
  local sub_txt_elems = {}
  local offset = -120
  for i = 0,inv:get_size("main"),1 do
    local stack = inv:get_stack("main", i)
    local item_name = stack:get_name()
    local definition = minetest.registered_nodes[item_name]
    if definition ~= nil and (definition.throwable_by_hand ~= nil or definition.bullet ~= nil) then
      sub_img_elems[item_name .. "_icon"] = {
        scale     = { x = 2, y = 2 },
        offset    = { x = 10, y = offset },
        alignment = { x = 1, y = 0 },
        text      = definition.inventory_image,
        z_index   = 1
      }
      sub_img_elems[item_name .. "_bg"] = {
        scale     = { x = 2, y = 2 },
        offset    = { x = 10, y = offset },
        alignment = { x = 1, y = 0 },
        text      = "background_weapons.png",
        z_index   = 0
      }

      local conto = 0
      if definition.bullet then
        for i=0,inv:get_size("main"),1 do
          local stack = inv:get_stack("main", i)
          local item_name = stack:get_name()
          if item_name == definition.bullet then
            conto = stack:get_count()
            break
          end
        end
      end
      local conto_proiettili = definition.throwable_by_hand and stack:get_count() or conto
      --[[
      sub_txt_elems[definition.name .. "_count_txt"] = {
          alignment = { x = 1, y = 0 },
          offset    = { x = 50, y = offset },
          --text      = ((definition.consume_bullets or definition.consume_on_throw) and conto_proiettili or "-1") .. " | " .. (definition.reload and definition.reload or "-1"),
          text      = (definition.consume_bullets or definition.consume_on_throw) and conto_proiettili or "-1",
          z_index   = 1
      }]]

      sub_txt_elems[definition.name .. "_reload_txt"] = {
          alignment = { x = 3, y = 0 },
          offset    = { x = 50, y = offset },
          text      = definition.reload and definition.reload or "-1",
          z_index   = 1
      }
      offset = offset - 50
    end

  end

  local panel = Panel:new({
      name = "bullets_hud",
      player = p_name,
      bg = "",
      position = { x = 0, y = 1 },
      alignment = { x = -1, y = 0 },
      title = "",

      sub_img_elems = sub_img_elems,

      sub_txt_elems = sub_txt_elems
    })

end

function get_bullet_count(definition, inv)
  if definition.throwable_by_hand then
    return stack:get_count()
  else
    local conto = 0
    if definition.bullet then
      for i=0,inv:get_size("main"),1 do
        local stack = inv:get_stack("main", i)
        local item_name = stack:get_name()
        if item_name == definition.bullet then
          return stack:get_count()
        end
      end
    end
  end
end

function block_league.weapons_hud_update(arena, p_name, item_name, bullet_count, reload_count)
  local definition = minetest.registered_nodes[item_name]
  local panel = panel_lib.get_panel(p_name, "bullets_hud")
  panel:update(nil,
    {
    --[[
    [definition.name .. "_count_txt"] = {
      --text = ((bullet_count ~= nil) and bullet_count or (panel[definition.name .. "_count_txt"].text - 1)) .. " | " .. ((reload_count ~= nil) and reload_count or (panel[definition.name .. "_reload_txt"].text - 1))
      text = (bullet_count ~= nil) and bullet_count or (panel[definition.name .. "_count_txt"].text ~= "-1" and (panel[definition.name .. "_count_txt"].text - 1) or "-1")
    },]]

    [definition.name .. "_reload_txt"] = {
      text = (reload_count ~= nil) and reload_count or (panel[definition.name .. "_reload_txt"].text ~= "-1" and (panel[definition.name .. "_reload_txt"].text - 1) or "- 1")
    }
  })
end
