-- questi gruppi vengono usati su weapons.lua per capire come renderizzare l'arma
if visible_wielditem then
	visible_wielditem.item_tweaks["groups"]["bl_sword"] = {
		rotation = {x=0, y=0, z=-60},
		position = {x=0, y=-0.3, z=0.35}
	}

	visible_wielditem.item_tweaks["groups"]["bl_weapon"] = {
		rotation = {x=180, y=0, z=280},
		position = {x=0, y=-0.3, z=0.35}
	}
	
	visible_wielditem.item_tweaks["groups"]["bl_weapon_mesh"] = {
		rotation = {x=0, y=0, z=-100},
		position = {x=0, y=-0.15, z=0.2},
		scale = 1.4
	}

	visible_wielditem.item_tweaks["groups"]["bouncer"] = {
		rotation = {x=180, y=0, z=300},
		position = {x=0, y=-0.15, z=0},
		scale = 0.75
	}
end
