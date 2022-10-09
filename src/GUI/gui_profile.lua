local S = minetest.get_translator("block_league")

local function get_formspec() end
local function get_elem_info() end

function block_league.show_profile(p_name)
  minetest.show_formspec(p_name, "block_league:profile", get_formspec(p_name))
end

function get_formspec(p_name)
  local p_props = minetest.get_player_by_name(p_name):get_properties()
  local p_skill = block_league.get_player_skill(p_name)

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
    "model[0,0.35;5,3.6;chara;" .. p_props.mesh .. ";" .. p_props.textures[1] .. ";0,-150;false;true]",
    -- caselle equipaggiamento
    "container[0.42,4.25]",
    "image[0,0;1,1;bl_gui_profile_button_weap.png]",
    "image[1.05,0;1,1;bl_gui_profile_button_weap.png]",
    "image[2.1,0;1,1;bl_gui_profile_button_weap.png]",
    "image[3.15,0;1,1;bl_gui_profile_button_skill.png]",
    "item_image_button[0.1,0.08;0.82,0.82;block_league:smg;weap1;]",
    "item_image_button[1.15,0.08;0.82,0.82;block_league:sword;weap2;]",
    "item_image_button[2.2,0.08;0.82,0.82;block_league:pixelgun;weap3;]",
    "image_button[3.25,0.08;0.82,0.82;bl_skill_" .. p_skill:sub(14, -1) .. ".png;skill;]",
    "tooltip[skill;" .. skillz.get_skill_def(p_skill).name .. "]",
    "container_end[]",
    "container[0.85,5.66]",
    "image[0,0;1.53,1.53;bl_gui_profile_button_skillpick.png]",
    "image[1.7,0;1.53,1.53;bl_gui_profile_button_skillpick.png]",
    "image_button[0,0;1.53,1.53;bl_skill_hp.png;hp;]",
    "image_button[1.7,0;1.53,1.53;bl_skill_sp.png;sp;]",
    "container_end[]"
  }

  local info_section = {}
  local elem = minetest.get_player_by_name(p_name):get_meta():get_string("bl_profile_elem_active")

  if elem ~= "" then
    local item = ""
    local is_skill = false;
    if skillz.get_skill_def("block_league:" .. elem) then
      is_skill = true
      item = "image[7,1.7;1,1;bl_skill_" .. elem .. ".png]"
    else
      --item = "model[TODO, per le armi]"
    end

    local elem_name, elem_desc = get_elem_info(elem, is_skill)

    info_section = {
      item,
      "hypertext[5.5,2.85;4,2;elem_name;<global size=24><b>" .. elem_name .. "</b>]",
      "hypertext[5.5,3.5;4,4;elem_desc;<global size=16><i>" .. elem_desc .. "</i>]",
      "image_button[6.4,6.2;2.2,0.8;bl_gui_profile_button_confirm.png;equip;" .. S("EQUIP") .. "]"
    }
  else
    info_section = { "hypertext[5.5,1.7;4,6;item_desc;<global size=16 color=#abc0c0><i>" .. S("Welcome to your Block League profile!") .. "\n"
      .. S("Here you can change your passive skill: select one from the panel on the left to know more about it") .. "\n\n"
      .. S("More customisations will be possible in the future@1 (donations help)", "<style color=#7a9090>") .. "</style></i>"
    }
  end

  table.insert_all(formspec, info_section)

  return table.concat(formspec, "")
end



function get_elem_info(elem, is_skill)
  local name, desc
  if is_skill then
    local skill = skillz.get_skill_def("block_league:" .. elem)
    name = skill.name
    desc = skill.profile_description
  else
    name = "TODO"
    desc = "TODO"
  end

  return name, desc
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
  elseif fields.equip then
    --TODO: weapons too, prob using another metadata to track whether is a weapon or a skill
    local skill = "block_league:" .. player:get_meta():get_string("bl_profile_elem_active")

    -- evita di reinviare il formspec e di far chiamate allo spazio d'archiviazione se è la stessa abilità
    if block_league.get_player_skill(p_name) == skill then return end

    block_league.set_player_skill(p_name, skill)
    minetest.sound_play("bl_gui_equip_confirm", {to_player = p_name})
  end

  minetest.show_formspec(p_name, "block_league:profile", get_formspec(p_name))
end)
