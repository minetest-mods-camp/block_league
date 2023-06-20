local S = minetest.get_translator("block_league")

local function get_formspec() end



function block_league.show_profile(p_name)
  minetest.show_formspec(p_name, "block_league:profile", get_formspec(p_name))
end



function get_formspec(p_name)
  local p_props   = minetest.get_player_by_name(p_name):get_properties()
  local p_weaps   = block_league.get_player_weapons(p_name)
  local p_skill   = block_league.get_player_skill(p_name)
  local skill_def = skills.get_skill_def(p_skill)
  local info_section = {}
  local elem = minetest.get_player_by_name(p_name):get_meta():get_string("bl_profile_elem_active")

  -- calcolo contenuto da metter sulla destra
  if elem == "" then
    info_section = { "hypertext[0.3,1;4.48,7;elem_desc;<global size=15 halign=center valign=middle><i>" .. S("Welcome to your Block League profile!") .. "\n"
      .. S("Here you can learn about weapons and change your passive skill: select one from the panel on the left to know more about it") .. "\n\n"
      .. S("More customisations will be possible in the future@1 (donations help)", "<style color=#7a9090>") .. "</style></i>]"
    }

  else
    local item, elem_name, body, button
    local weap = minetest.registered_items["block_league:" .. elem]
    local skill = skills.get_skill_def("block_league:" .. elem)

    -- se è un'arma..
    if weap then
      item = weap.mesh and "model[0,1.5;5.08,2.2;weap_model;" .. weap.mesh .. ";" .. table.concat(weap.tiles, ",") .. ";0,140;false;true]"
                       or "image[2,1.7;1.5,1.5;" .. weap.wield_image .. "]"
      elem_name = weap.description

      local action_y = 0
      local action1, action1_hold, action1_air, action2, action2_hold, action2_air

      -- azioni varie
      if weap.action1 then
        action1 = "image[0," .. action_y .. ";0.4,0.55;bl_gui_profile_action_lmb.png]" ..
                  "hypertext[0.6," .. action_y - 0.12 .. ";3.8,0.8;elem_desc;<global size=15 valign=middle><i>" .. weap.action1.description .. "</i>]"
        action_y = action_y + 0.8
      end

      if weap.action1_hold then
        action1_hold = "image[0," .. action_y .. ";0.4,0.55;bl_gui_profile_action_lmb_hold.png]" ..
                  "hypertext[0.6," .. action_y - 0.12 .. ";3.8,0.8;elem_desc;<global size=15 valign=middle><i>" .. weap.action1_hold.description .. "</i>]"
        action_y = action_y + 0.8
      end

      if weap.action1_air then
        action1_air = "image[0," .. action_y .. ";0.4,0.55;bl_gui_profile_action_lmb_air.png]" ..
                  "hypertext[0.6," .. action_y - 0.12 .. ";3.8,0.8;elem_desc;<global size=15 valign=middle><i>" .. weap.action1_air.description .. "</i>]"
        action_y = action_y + 0.8
      end

      if weap.action2 then
        action2 = "image[0," .. action_y .. ";0.4,0.55;bl_gui_profile_action_rmb.png]" ..
                  "hypertext[0.6," .. action_y - 0.12 .. ";3.8,0.8;elem_desc;<global size=15 valign=middle><i>" .. weap.action2.description .. "</i>]"
        action_y = action_y + 0.8
      end

      if weap.action2_hold then
        action2_hold = "image[0," .. action_y .. ";0.4,0.55;bl_gui_profile_action_rmb_hold.png]" ..
                  "hypertext[0.6," .. action_y - 0.12 .. ";3.8,0.8;elem_desc;<global size=15 valign=middle><i>" .. weap.action2_hold.description .. "</i>]"
        action_y = action_y + 0.8
      end

      if weap.action2_air then
        action1_air = "image[0," .. action_y .. ";0.4,0.55;bl_gui_profile_action_rmb_air.png]" ..
                  "hypertext[0.6," .. action_y - 0.12 .. ";3.8,0.8;elem_desc;<global size=15 valign=middle><i>" .. weap.action2_air.description .. "</i>]"
        action_y = action_y + 0.8
      end

      local ammo = ""
      if weap.weapon_type ~= "melee" then
        ammo = table.concat({
          "image[0,1.6;0.4,0.4;bl_gui_profile_weapon_magazine.png]",
          "image[3,1.6;0.4,0.4;bl_gui_profile_weapon_reload.png]",
          "hypertext[0.6,1.53;1,0.6;elem_desc;<global size=16 valign=middle><i>" .. weap.magazine .. "  / --</i>]",
          "hypertext[3.6,1.53;1,0.6;elem_desc;<global size=16 valign=middle><i>" .. weap.reload_time .. "</i>]"
        })
      end

      local attributes = table.concat({
        "container[0.4,5.1]",
        action1       or "",
        action1_hold  or "",
        action1_air   or "",
        action2       or "",
        action2_hold  or "",
        action2_air   or "",
        ammo,
        "container_end[]",
      }, "")

      body = table.concat({
        "hypertext[0.3,4.2;4.48,0.7;elem_desc;<global size=15 halign=center valign=middle><style color=#abc0c0><i>" .. weap.profile_description .. "</i>]",
        attributes
      }, "")
      --TODO: inserire il pulsante "rimuovi" per quando si potrà cambiare equipaggiamento

    -- se è un'abilità..
    elseif skill then
      item = "image[2,1.7;1.5,1.5;bl_skill_" .. elem .. ".png]"
      elem_name = skill.name
      body = "hypertext[0.3,4.2;4.48,4.3;elem_desc;<global size=15 halign=center><style color=#abc0c0><i>" .. skill.profile_description .. "</i>]"

      if "block_league:" .. elem ~= p_skill then
        button = "image_button[1.45,7.9;2.2,0.8;bl_gui_profile_button_confirm.png;equip;" .. S("EQUIP") .. "]"
      end
    end

    info_section = {
      item,
      "hypertext[0,0.35;5.08,0.8;elem_name;<global size=24 valign=middle halign=center><b>" .. elem_name .. "</b>]",
      body,
      button
    }
  end

  local right_elem = table.concat(info_section, "")

  -- corpo
  local formspec = {
    "formspec_version[4]",
    "size[19,9,true]",
    "no_prepend[]",
    "background[0,0;19,9;bl_gui_profile_bg.png]",
    "bgcolor[;true]",
    "style_type[item_image_button;border=false]",
    "style_type[image_button;border=false]",
    "style[weap,wslot,sslot;font=mono;textcolor=#00000000]",
    "listcolors[#ffffff;#ffffff;#ffffff;#3153b7;#ffffff]",

    -- parte sinistra
    "model[0.08,0.8;5.08,3.6;chara;" .. p_props.mesh .. ";" .. table.concat(p_props.textures, ",") .. ";0,-150;false;true]",
    "container[0.49,5]",
    "image[0,0;1.05,1.05;bl_gui_profile_button_weap.png]]",
    "image[1.1,0;1.05,1.05;bl_gui_profile_button_weap.png]",
    "image[2.2,0;1.05,1.05;bl_gui_profile_button_weap.png]",
    "image[3.3,0;1.05,1.05;bl_gui_profile_button_skill.png]",
    "image_button[0.1,0.11;0.85,0.85;" .. minetest.registered_nodes[p_weaps[1]].inventory_image .. ";weap;1]",
    "image_button[1.2,0.11;0.85,0.85;" .. minetest.registered_nodes[p_weaps[2]].inventory_image .. ";weap;2]",
    "image_button[2.3,0.11;0.85,0.85;" .. minetest.registered_nodes[p_weaps[3]].inventory_image .. ";weap;3]",
    "image_button[3.4,0.11;0.85,0.85;" .. skill_def.icon .. ";skill;]",
    "tooltip[skill;" .. skill_def.name .. "]",
    "container[0.05,1.55]",
    "image[0,0;0.8,0.8;bl_rank_beginner.png]",
    "hypertext[0.9,0;3.25,0.8;pname_txt;<global size=24 valign=middle><b>" .. p_name .. "</b>]",
    "image[0.05,1;0.22,0.22;bl_gui_profile_infobox_trophies.png]",
    "image[0.05,1.8;0.22,0.3;bl_gui_profile_infobox_money.png]",
    "hypertext[0.4,0.94;3.35,0.4;pname_txt;<global size=14 valign=middle><b>---</b>]",
    "hypertext[0.4,1.78;3.35,0.4;pname_txt;<global size=14 valign=middle><b>---</b>]",
    "container_end[]",
    "container_end[]",

    -- parte centrale
    "container[5.85,0.35]",
    "hypertext[0,0;3.35,0.9;weap_txt;<global size=24 valign=middle><style color=#5be7b1><b>" .. S("Weapons") .. "</b>]",
    "image[0,1;1.05,1.05;bl_gui_profile_inv_weapon_unlocked.png]",
    "image[1.25,1;1.05,1.05;bl_gui_profile_inv_weapon_unlocked.png]",
    "image[2.5,1;1.05,1.05;bl_gui_profile_inv_weapon_unlocked.png]",
    "image[3.75,1;1.05,1.05;bl_gui_profile_inv_weapon_locked.png]",
    "image_button[0.1,1.11;0.85,0.85;bl_smg.png;wslot;smg]",
    "image_button[1.35,1.11;0.85,0.85;bl_sword.png;wslot;sword]",
    "image_button[2.6,1.11;0.85,0.85;bl_pixelgun.png;wslot;pixelgun]",
    "image[3.85,1.11;0.85,0.85;bl_rocketlauncher_icon.png^[multiply:#777777]",
    "hypertext[3.78,1.05;0.95,0.95;soon_tm;<global size=14 halign=center valign=middle><style color=#abc0c0><b>" .. S("Soon") .. "</b>]",
    "container[0,4.5]",
    "hypertext[0,0;3.35,0.9;weap_txt;<global size=24 valign=middle><style color=#5be7b1><b>" .. S("Skills") .. "</b>]",
    "image[0,1;1.05,1.05;bl_gui_profile_inv_skill_unlocked.png]",
    "image[1.25,1;1.05,1.05;bl_gui_profile_inv_skill_unlocked.png]",
    "image[2.5,1;1.05,1.05;bl_gui_profile_inv_skill_locked.png]",
    "image_button[0.1,1.11;0.85,0.85;bl_skill_hp.png;sslot;hp]",
    "image_button[1.35,1.11;0.85,0.85;bl_skill_sp.png;sslot;sp]",
    "image[2.6,1.11;0.85,0.85;bl_skill_shield.png^[multiply:#777777]",
    "hypertext[2.53,1.05;0.95,0.95;soon_tm;<global size=14 halign=center valign=middle><style color=#abc0c0><b>" .. S("Soon") .. "</b>]",
    "container_end[]",
    "container_end[]",

    -- parte destra
    "container[13.88,0]",
    right_elem,
    "container_end[]"
  }

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

  if fields.weap then
    player:get_meta():set_string("bl_profile_elem_active", string.sub(block_league.get_player_weapons(p_name)[tonumber(fields.weap)], 14, -1))
  elseif fields.skill then
    player:get_meta():set_string("bl_profile_elem_active", string.sub(block_league.get_player_skill(p_name), 14, -1))
  elseif fields.wslot then
    player:get_meta():set_string("bl_profile_elem_active", fields.wslot)
  elseif fields.sslot then
    player:get_meta():set_string("bl_profile_elem_active", fields.sslot)
  elseif fields.equip then
    local skill = "block_league:" .. player:get_meta():get_string("bl_profile_elem_active")

    block_league.set_player_skill(p_name, skill)
    minetest.sound_play("bl_gui_equip_confirm", {to_player = p_name})
  end

  minetest.show_formspec(p_name, "block_league:profile", get_formspec(p_name))
end)
