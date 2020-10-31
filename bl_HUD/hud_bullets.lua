local S = minetest.get_translator("block_league")

local function get_bullet_count() end



function block_league.bullets_hud_create(p_name)

  local inv = minetest.get_player_by_name(p_name):get_inventory()
  local sub_img_elems = {}
  local sub_txt_elems = {}
  local offset_x = -90        -- currently hardcoded for smg and pixelgun
  local offset_y = -125

  for i = 1, 3 do

    local stack = inv:get_stack("main", i)
    local item_name = stack:get_name()
    local weapon = minetest.registered_nodes[item_name]

    if weapon ~= nil and weapon.magazine ~= nil then
      sub_img_elems[item_name .. "_icon"] = {
        scale     = { x = 2, y = 2 },
        offset    = { x = offset_x, y = offset_y },
        alignment = { x = -1, y = 1 },
        text      = weapon.inventory_image,
        z_index   = 1
      }
      sub_img_elems[item_name .. "_bg"] = {
        scale     = { x = 2, y = 2 },
        offset    = { x = offset_x, y = offset_y },
        alignment = { x = 0, y = 1 },
        text      = "bl_hud_bullets_bg.png",
        z_index   = 0
      }

      sub_txt_elems[weapon.name .. "_magazine_txt"] = {
          alignment = { x = 0, y = 1 },
          offset    = { x = offset_x + 30, y = offset_y + 6 },
          text      = weapon.magazine and weapon.magazine or "-1",
          z_index   = 1
      }
      offset_x = offset_x + 180   -- same as before
    end

  end

  -- creo pannello
  Panel:new({
    name = "bl_bullets",
    player = p_name,
    bg = "",
    position = { x = 0.5, y = 1 },
    alignment = { x = 0, y = 0 },
    title = "",

    sub_img_elems = sub_img_elems,
    sub_txt_elems = sub_txt_elems
  })

end



function get_bullet_count(definition, inv)
  if not definition.bullet then return end

  for i=0,inv:get_size("main"),1 do

    local stack = inv:get_stack("main", i)
    local item_name = stack:get_name()

    if item_name == definition.bullet then
      return stack:get_count()
    end
  end
end



function block_league.weapons_hud_update(arena, p_name, item_name, magazine)
  local weapon_def = minetest.registered_nodes[item_name]
  local panel = panel_lib.get_panel(p_name, "bl_bullets")

  panel:update(nil,
    {
    [weapon_def.name .. "_magazine_txt"] = {
      text = magazine
    }
  })

  --TODO: cambiare colore a seconda del numero proiettili (le immagini già ci sono)
end
