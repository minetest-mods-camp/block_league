# Block League

S4 League inspired shooter minigame for Minetest.

Zughy <a href="https://liberapay.com/Zughy/"><img src="https://i.imgur.com/4B2PxjP.png" alt="Support Zughy"/></a> | Zaizen <a href="https://liberapay.com/_Zaizen_/"><img src="https://i.imgur.com/4B2PxjP.png" alt="Support Zaizen"/></a>  

### Dependencies
* [achievements_lib](https://gitlab.com/zughy-friends-minetest/achievements_lib) by me
* [arena_lib](https://gitlab.com/zughy-friends-minetest/arena_lib/) by me
* (bundled by arena_lib) [ChatCMDBuilder](https://github.com/rubenwardy/ChatCmdBuilder/) by rubenwardy
* [controls](https://github.com/Arcelmi/minetest-controls) by Arcelmi
* [panel_lib](https://gitlab.com/zughy-friends-minetest/panel_lib) by me
* [skillz](https://gitlab.com/zughy-friends-minetest/skillz) by Giov4

### Set up an arena
1. run `/bladmin create <arena_name> <mode>`, where `mode` is `1` for Touchdown and `2` for Deathmatch
2. enter the editor via `/bladmin edit <arena_name>`
3. have fun customising it

If it's TD, you must also
1. set the two goals via `/bladmin goal [set|remove] <arena_name> <team_name>`
2. set the two waiting rooms via `/bladmin wroom [set|remove] <arena_name> <team_name>`
3. set the ball spawn point via `/bladmin ball [set|remove] <arena_name>`  

(one day™ these 3 last steps will be included in the editor... maybe)

### Utility commands
* `/bladmin list`: list all arenas
* `/bladmin info <arena_name>`: list all the info about the specific arena
* `/bladmin testkit`: gives you the bouncer and the in-game physics, to easily test your maps. The last object in the hotbar restores your inventory and physics

### Want to help?
Feel free to:
* open an [issue](https://gitlab.com/zughy-friends-minetest/block_league/-/issues)
* submit a merge request. In this case, PLEASE, do follow milestones and my [coding guidelines](https://cryptpad.fr/pad/#/2/pad/view/-l75iHl3x54py20u2Y5OSAX4iruQBdeQXcO7PGTtGew/embed/). I won't merge features for milestones that are different from the upcoming one (if it's declared), nor messy code
* contact me on Matrix, on my server [dev room](https://matrix.to/#/!viLipqDNOHxQJqQRGI:matrix.org)

### Resources
2D graphic assets by me  
3D models by Scarecrow01  
Bouncer sound by [iozonic](https://freesound.org/people/iozonic/sounds/380763/)  
HMG shooting sound by [tcpp](https://freesound.org/people/tcpp/sounds/105025/)  
Pixelgun shooting sound by [debsound](https://freesound.org/people/debsound/sounds/339169/)  
Pixelgun reloading sound by [GreenFireSound](https://freesound.org/people/GreenFireSound/sounds/484113/) and [JarAxe](https://freesound.org/people/JarAxe/sounds/205969/)  
Rocket launcher shooting sound by [Audionautics](https://freesound.org/people/Audionautics/sounds/171655/)  
Shotgun shooting sound by [coolguy](https://freesound.org/people/coolguy244e/sounds/266977/)  
Shotgun reloading sound by [jeseid77](https://freesound.org/people/jeseid77/sounds/86246/)  
SMG shooting sound by [kafokafo](https://freesound.org/people/kafokafo/sounds/128229/)  
SMG shooting sound by [GreenFireSound](https://freesound.org/people/GreenFireSound/sounds/484113/)  
Sword dash by [LloydEvans09](https://freesound.org/people/LloydEvans09/sounds/185849/)  
Sword swing by [bay_area_bob](https://freesound.org/people/bay_area_bob/sounds/541996/)  
Hit sound by [cabled_mess](https://freesound.org/people/cabled_mess/sounds/350926/)  
Critical sound by [EFlexMusic](https://freesound.org/people/EFlexMusic/sounds/418324/)  
Kill sound by [jmayoff](https://freesound.org/people/jmayoff/sounds/255156/)  
Countdown announcer by [dbosst](https://freesound.org/people/dbosst/sounds/464145/)  
"Fight" announcer by [EFlexMusic](https://freesound.org/people/EFlexMusic/)  
Crowd cheering by [wangzhuokun](https://freesound.org/people/wangzhuokun/sounds/442583/)  
Crowd "oh no" by [dobroide](https://freesound.org/people/dobroide/sounds/35034/)  
Ball "resetting" voice by [tim.kahn](https://freesound.org/people/tim.kahn/sounds/107546/)  
Victory jingle by [unadamlar](https://freesound.org/people/unadamlar/sounds/341985/)  
Defeat jingle by [soundmonster0](https://freesound.org/people/soundmonster0/sounds/533925/)  
GUI equip sound by [EminYILDIRIM](https://freesound.org/people/EminYILDIRIM/sounds/588681/)

Most audio files have been tweaked by me

---

Images and models are under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
