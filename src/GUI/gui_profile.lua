local S = minetest.get_translator("block_league")

local function get_formspec() end



function block_league.show_profile(p_name)
  minetest.show_formspec(p_name, "block_league:profile", get_formspec(p_name))
end



function get_formspec(p_name)
  local p_props = minetest.get_player_by_name(p_name):get_properties()
  local p_weaps = block_league.get_player_weapons(p_name)
  local p_skill = block_league.get_player_skill(p_name)

  -- parte sinistra
  local formspec = {
    "formspec_version[4]",
    "size[10,7.6]",
    "no_prepend[]",
    "background[0,0;10,7.6;bl_gui_profile_bg.png]",
    "bgcolor[;true]",
    "style_type[item_image_button;border=false]",
    "style_type[image_button;border=false]",
    "listcolors[#ffffff;#ffffff;#ffffff;#3153b7;#ffffff]",
    "style[hp;padding=15]",
    "style[sp;padding=15]",
    "model[0,0.35;5,3.6;chara;" .. p_props.mesh .. ";" .. table.concat(p_props.textures, ",") .. ";0,-150;false;true]",
    -- caselle equipaggiamento
    "container[0.42,4.25]",
    "image[0,0;1,1;bl_gui_profile_button_weap.png]",
    "image[1.05,0;1,1;bl_gui_profile_button_weap.png]",
    "image[2.1,0;1,1;bl_gui_profile_button_weap.png]",
    "image[3.15,0;1,1;bl_gui_profile_button_skill.png]",
    "item_image_button[0.1,0.08;0.82,0.82;" .. p_weaps[1] .. ";weap1;]",
    "item_image_button[1.15,0.08;0.82,0.82;" .. p_weaps[2] .. ";weap2;]",
    "item_image_button[2.2,0.08;0.82,0.82;" .. p_weaps[3] .. ";weap3;]",
    "image_button[3.25,0.08;0.82,0.82;" .. skillz.get_skill_def(p_skill).icon .. ";skill;]",
    "tooltip[skill;" .. p_skill .. "]",
    "container_end[]",
    "container[0.85,5.66]",
    "image[0,0;1.53,1.53;bl_gui_profile_button_skillpick.png]",
    "image[1.7,0;1.53,1.53;bl_gui_profile_button_skillpick.png]",
    "image_button[0,0;1.53,1.53;bl_skill_hp.png;hp;]",
    "image_button[1.7,0;1.53,1.53;bl_skill_sp.png;sp;]",
    "container_end[]"
  }

  -- parte destra
  local info_section = {}
  local elem = minetest.get_player_by_name(p_name):get_meta():get_string("bl_profile_elem_active")

  if elem == "" then
    info_section = { "hypertext[5.5,1.7;4,6;item_desc;<global size=16 color=#abc0c0><i>" .. S("Welcome to your Block League profile!") .. "\n"
      .. S("Here you can learn about weapons and change your passive skill: select one from the panel on the left to know more about it") .. "\n\n"
      .. S("More customisations will be possible in the future@1 (donations help)", "<style color=#7a9090>") .. "</style></i>"
    }

  else
    local item, elem_name, elem_desc, properties, button
    local weap = minetest.registered_items["block_league:" .. elem]
    local skill = skillz.get_skill_def("block_league:" .. elem)

    -- se è un'arma..
    if weap then

      item = weap.mesh and "model[6.5,1;2,2;weap_model;" .. weap.mesh .. ";" .. table.concat(weap.tiles, ",") .. ";0,140;false;true]"
                       or "image[6.75,1.2;1.5,1.5;" .. weap.wield_image .. "]"

      elem_name = weap.description
      elem_desc = weap.profile_description

      properties = {}
      local prop = ""
      local prop_y = 1

      -- calcolo le varie proprietà
      if weap.decrease_damage_with_distance then
        prop = "image[5.5," .. prop_y .. ";0.5,0.5;bl_gui_profile_prop_distance.png]tooltip[5.5," .. prop_y .. ";0.5,0.5;" .. S("Decrease damage with distance") .."]"
        prop_y = prop_y + 1
        table.insert(properties, prop)
      end

      if weap.pierce then
        prop = "image[5.5," .. prop_y .. ";0.5,0.5;bl_gui_profile_prop_pierce.png]tooltip[5.5," .. prop_y .. ";0.5,0.5;" .. S("Pierce through") .. "]"
        prop_y = prop_y + 1
        table.insert(properties, prop)
      end

      if next(properties) then
        properties = table.concat(properties, "")
      else
        properties = nil
      end

      --TODO: inserire il pulsante "rimuovi" per quando si potrà cambiare equipaggiamento

    -- se è un'abilità..
    elseif skill then

      item = "image[7,1.7;1,1;bl_skill_" .. elem .. ".png]"
      elem_name = skill.name
      elem_desc = skill.profile_description


      if "block_league:" .. elem ~= p_skill then
        button = "image_button[6.4,6.2;2.2,0.8;bl_gui_profile_button_confirm.png;equip;" .. S("EQUIP") .. "]"
      end
    end

    info_section = {
      item,
      "hypertext[5.5,2.85;4,2;elem_name;<global size=24><b>" .. elem_name .. "</b>]",
      "hypertext[5.5,3.5;4,2.6;elem_desc;<global size=16><i>" .. elem_desc .. "</i>]",
      properties,
      button
    }
  end

  table.insert_all(formspec, info_section)

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)

  if formname ~= "block_league:profile" then return end

  if fields.quit then
    player:get_meta():set_string("bl_profile_elem_active", "")
    return end

  local p_name = player:get_player_name()

  if fields.hp then
    player:get_meta():set_string("bl_profile_elem_active", "hp")
  elseif fields.sp then
    player:get_meta():set_string("bl_profile_elem_active", "sp")
  elseif fields.weap1 then
    player:get_meta():set_string("bl_profile_elem_active", string.sub(block_league.get_player_weapons(p_name)[1], 14, -1))
  elseif fields.weap2 then
    player:get_meta():set_string("bl_profile_elem_active", string.sub(block_league.get_player_weapons(p_name)[2], 14, -1))
  elseif fields.weap3 then
    player:get_meta():set_string("bl_profile_elem_active", string.sub(block_league.get_player_weapons(p_name)[3], 14, -1))
  elseif fields.equip then
    local skill = "block_league:" .. player:get_meta():get_string("bl_profile_elem_active")

    block_league.set_player_skill(p_name, skill)
    minetest.sound_play("bl_gui_equip_confirm", {to_player = p_name})
  end

  minetest.show_formspec(p_name, "block_league:profile", get_formspec(p_name))
end)
