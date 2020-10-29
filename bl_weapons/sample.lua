block_league.register_weapon("block_league:nomearma", {

  description = "descrizione", --Descrizione
  inventory_image = "inventory_image.png", --Immagine nell'inventario
  wield_scale = {x=1, y=1, z=1}, --Dimensione in mano

  --Se si vuole l'arma 3D
  mesh = "mesh.obj", --Modello
  tiles = {"tiles.png"}, --Textures del modello

  --Se si vuole l'arma 2D
  wield_image = "wield_image.png", --Immagine da mostrare in mano

  weap_sound_shooting = "weap_sound_shooting", --Suono quando si usa l'arma
  weap_delay = 10, --Delay tra gli spari
  weap_secondary_delay = 2, --Delay tra l'uso del destro


  type = 1, --1) Hitscan 2) Entity based 3) Sword
  range = 100, --Range nel quale opera il raggio hitscan
  continuos_fire = false, --Se può sparare tenendo premuto il sinistro
  slow_down_when_firing = true, --Se rallentare chi spara
  consume_bullets = true, --Se usa proiettili
  magazine = 0, --Dopo quanti colpi ricaricare
  reload_delay = 5,
  bullet = "block_league:nomeproiettile", --Che proiettile/granata spara aka quello che viene consumato all'uso
  on_right_click = function(arena, name, def, itemstack, user, pointed_thing) end, --Cosa fare quando si clicca destro

  type = 2, --1) Hitscan 2) Entity based 3) Sword
  continuos_fire = false, --Se può sparare tenendo premuto il sinistro
  slow_down_when_firing = true, --Se rallentare chi spara
  consume_bullets = true, --Se usa proiettili
  magazine = 0, --Dopo quanti colpi ricaricare
  reload_delay = 5,
  launching_force = 10,
  bullet = "block_league:nomeproiettile", --Che proiettile/granata spara
  on_right_click = function(arena, name, def, itemstack, user, pointed_thing) end, --Cosa fare quando si clicca destro

  type = 3, --1) Hitscan 2) Entity based 3) Sword
  weap_damage = 10, --Danno inflitto
  knockback = 0, --Il contraccolpo da applicare al bersaglio
  on_right_click = function(arena, name, def, itemstack, user, pointed_thing) end, --Cosa fare quando si clicca destro

})


block_league.register_bullet("block_league:nomeproiettile", {
  description = "descrizione", --Descrizione
  inventory_image = "inventory_image.png", --Immagine nell'inventario
  wield_scale = {x=1, y=1, z=1}, --Dimensione in mano

  --Se si vuole il proiettile 3D
  mesh = "mesh.obj", --Modello
  tiles = {"tiles.png"}, --Textures del modello

  --Se si vuole il proiettile 2D
  wield_image = "wield_image.png", --Immagine da mostrare in mano

  stack_max = 99, --Numero massimo di proiettili possedibili

  throwable_by_hand = true, --Se si può lanciare a mano
  consume_on_throw = true,

  impaling = true, --Se può attraversare il bersaglio NB: Utilizzabile solo con proiettili hitscan
  knockback = 0, --Il contraccolpo da applicare al bersaglio
  decrease_damage_with_distance = true, --Se il danno diminuisce con la distanza
  bullet_damage = 10, --Danno inflitto
  bullet_trail = {
    image = "weap_trail.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 20,
  },

  duration = 10, --Tempo di vita dell'entità (da spostare dentro bullet)

  bullet = {

    visual_size = {x=7, y=7, z=7}, --Dimensione in aria
    collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},

    --Se si vuole il proiettile 3D
    mesh = "mesh.obj", --Modello
    textures = {"textures.png"}, --Textures del modello

    --Se si vuole il proiettile 2D
    --Si può lasciare vuoto, prenderà in automatico la texture dell'item

    explode_on_contact = true, --Se rimbalza quando si scontra con qualcosa

    bullet_explosion_damage = 10, --Danno inflitto con l'esplosione
    bullet_explosion_range = 4, --Raggio dell'esplosione
    bullet_explosion_texture = "explosion_texture.png",

    bullet_speed = 30, --Velocità a cui lanciare/sparare il proiettile

    gravity = true, --Se la gravità ha effetto sul proiettile

    on_right_click = block_league.bullet_right_click, --Cosa fare quando si clicca destro sul proiettile
    on_destroy = block_league.bullet_on_destroy,

  }


})
