block_league.register_weapon("block_league:nomearma", {

  description = "descrizione",
  inventory_image = "inventory_image.png",
  wield_scale = {x=1, y=1, z=1},

  --Se si vuole l'arma 3D
  mesh = "mesh.obj",
  tiles = {"tiles.png"},

  --Se si vuole l'arma 2D
  wield_image = "wield_image.png",

  sound_shoot = "sound_shoot", --Suono quando si usa l'arma
  fire_delay = 10, --Delay tra gli spari
  weap_secondary_delay = 2, --Delay tra l'uso del destro


  weapon_type = 1, --1) Hitscan 2) Entity based 3) Sword
  weapon_range = 100, --Range nel quale opera il raggio hitscan
  continuos_fire = false, --Se può sparare tenendo premuto il sinistro
  consume_bullets = true, --Se usa proiettili
  magazine = 0, --Dopo quanti colpi ricaricare
  reload_time = 5,
  bullet = "block_league:nomeproiettile", --Che proiettile/granata spara
  on_right_click = function(arena, name, def, itemstack, user, pointed_thing) end, --Cosa fare quando si clicca destro

  damage = 10, --Danno inflitto
  knockback = 0, --Il contraccolpo da applicare al bersaglio
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

  pierce = true, --Se può attraversare il bersaglio NB: Utilizzabile solo con proiettili hitscan
  knockback = 0, --Il contraccolpo da applicare al bersaglio
  decrease_damage_with_distance = true, --Se il danno diminuisce con la distanza
  bullet_damage = 10, --Danno inflitto
  bullet_trail = {
    image = "bullet_trail.png",
    life = 1,
    size = 2,
    glow = 0,
    interval = 5,
    amount = 20,
  },

  lifetime = 10, --Tempo di vita dell'entità (TODO: da spostare dentro bullet)

  bullet = {

    visual_size = {x=7, y=7, z=7},
    collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},

    --Se si vuole il proiettile 3D
    mesh = "mesh.obj",
    textures = {"textures.png"},

    --Se si vuole il proiettile 2D
    --Si può lasciare vuoto, prenderà in automatico la texture dell'item

    explode_on_contact = true, --Se rimbalza quando si scontra con qualcosa

    explosion_damage = 10, --Danno inflitto con l'esplosione
    explosion_range = 4, --Raggio dell'esplosione
    explosion_texture = "explosion_texture.png",

    speed = 30, --Velocità a cui lanciare/sparare il proiettile
    gravity = true, --Se la gravità ha effetto sul proiettile

    on_right_click = block_league.bullet_right_click, --Cosa fare quando si clicca destro sul proiettile
    on_destroy = block_league.bullet_on_destroy,

  }
})
