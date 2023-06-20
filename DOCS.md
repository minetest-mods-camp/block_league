(WIP)

## Weapon structure
* `weapon_type`: (string) can be `"gun"`, `"melee"`, `"snipe"` or `"support"`. A gun can have melee functions, but not viceversa
* `action1`: (table) action on left click
* `action2`: (table) action on right click
* `action1_hold`: (table, melee only) action on left click if kept pressed for 0.3s. NOT YET IMPLEMENTED
* `action2_hold`: (table, melee only) action on right click if kept pressed for 0.3s. NOT YET IMPLEMENTED
* `action1_air`: (table, melee only) action on left click whilst in the air
* `action2_air`: (table, melee only) action on right click whilst in the air
* `magazine`: (int, no melee) how many bullets the magazine contains
* `reload_time`: (int, no melee) how much time it takes to reload the weapon
* `sound_reload`: (string, no melee) the sound the weapon does when reloading, without the format at the end

### Actions structure
* `type`: (string) can be `"raycast"`, `"bullet"`, `"zoom"`, `"install"`, `"melee"`, `"parry"` or `"custom"`
* `description`: (string) what the action does. Displayed in formspecs
* `damage`: (float) how much damage deals
* `range`: (float, no punch) range of the weapon
* `delay`: (float) how much time it should pass between being able to rerun the action
* `loading_time`: (float) how much time before actually running the action. NOT YET IMPLEMENTED
* `knockback`: (int) how much knockback the weapon should have
* `ammo_per_use`: (int, no punch) how much ammo is needed to run the action
* `physics_override`: (table or string) how the player physics should change when running the action. It takes either a Minetest phyiscs table or the string "FREEZE", which will block the player. Physics is restored when the action ends
* `decrease_damage_with_distance`: (bool) whether damage should decrease as the distance from the target increases. Default is `false`
* `continuous_fire`: (bool, no punch) whether it should keep firing when holding down the action key (waiting `delay` seconds between a shot and another). Default is `false`
* `attack_on_release`: (bool) whether it should attack when the action key is released. NOT YET IMPLEMENTED
* `pierce`: (bool) whether the hit should stop on the first person or continue. Default is `false`
* `sound`: (string) the sound to play when the action is run
* `trail`: (table) the trail the action should leave. Fields are:
  * `image`: (string) the particle to spawn
  * `amount`: (int) how many particles to draw along the line
* `on_use`: (function(player, weapon, action, pointed_thing), custom only) the behaviour of the custom action

## Notes
* `*_hold` actions are not implemented due to wielditem animations not being customisable. People would be confused. See: https://github.com/minetest/minetest/issues/2811
* same applies for `loading_time`
* `attack_on_release` needs https://github.com/minetest/minetest/issues/13581 to run properly (I only need it for the pixelgun at the moment)
* `bl_weapon_state` metadata communicates the state of the weapon:
  * `0`: free
  * `1`: loading, NOT YET IMPLEMENTED
  * `2`: shooting
  * `3`: recovering
  * `4`: reloading
  * `5`: parrying, NOT YET IMPLEMENTED