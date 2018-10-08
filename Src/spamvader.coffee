squadrons = turrets = explosions = shots = undefined

NONE = 0; TRIPLE = 1; BURST = 2; BEAM = 3

explosionData =
  small: { file: "smallerExplosion.png", frames: [60, 60, 5, 2], sound: "siclone_explosion_small.wav", ticks: 3 }
  large: { file: "largerExplosion.png", frames: [92, 92, 5, 2], sound: "siclone_explosion.wav", ticks: 4 }
  beam:  { file: "beam.png", frames: [64, 64, 8, 5], sound: "siclone_explosion.wav", ticks: 1 }
  hyper: { file: "hyper.png", frames: [512, 512, 8, 5], sound: "siclone_saucer.wav", ticks: 1 }
  
shotData =
  null:  { speed: 0, power: 0, radius: 0, explosion: explosionData.small }
  pea:   { speed: 2, power: 1, radius: 32, explosion: explosionData.small }
  shell: { speed: 2, power: 3, radius: 58, explosion: explosionData.large }
  beam:  { speed: 16, power: 10, radius: 32, explosion: explosionData.beam }
  hyper: { speed: 32, power: 100, radius: 96, explosion: explosionData.hyper }
  scatt: { speed: 2, power: 3, radius: 58, explosion: explosionData.large }

turretData =
  none:   { name: "", cost: 0, frames: [4, 5], sound: "siclone_shoot.wav", shotType: 0, cooldown: 0, colour: "grey", effect: NONE }
  pea:    { name: "PEA", cost: 100, frames: [1, 0], sound: "siclone_shoot_enemy.wav", shotType: shotData.pea, cooldown: 60, colour: "pink", effect: BURST }
  cannon: { name: "CANNON", cost: 1000, frames: [2, 0], sound: "siclone_shoot.wav", shotType: shotData.shell, cooldown: 120, colour: "yellow", effect: BURST }
  beam:   { name: "BEAM", cost: 1500, frames: [0, 2], sound: "siclone_shoot.wav", shotType: shotData.beam, cooldown: 420, colour: "green", effect: BEAM }
  triple: { name: "TRIPLE", cost: 12000, frames: [3, 2], sound: "siclone_shoot.wav", shotType: shotData.shell, cooldown: 140, colour: "blue", effect: TRIPLE }
  scatt:  { name: "SCATTER", cost: 30000, frames: [6, 2], sound: "siclone_shoot.wav", shotType: shotData.scatt, cooldown: 160, colour: "grey", effect: BURST }
  hyper:  { name: "HYPER", cost: 50000, frames: [2, 2], sound: "siclone_shoot.wav", shotType: shotData.hyper, cooldown: 640, colour: "purple", effect: BEAM }
  
cash = 0
wave = 0
time = 0

canvas = context = state = undefined
turretSprites = alienSprites = undefined
selection = -1
upgradeTarget = -1
mouse = { x: 0, y: 0 }

onload = ->
  canvas = document.createElement 'canvas'
  canvas.width = 640
  canvas.height = 480
  canvas.style.width = (canvas.width * 2) + "px"
  canvas.style.height = (canvas.height * 2) + "px"
  context = canvas.getContext('2d')

  document.body.appendChild canvas
  
  for key, data of explosionData
    img = new Image()
    img.src = "Images/" + data.file
    data.img = img
    
  img = new Image()
  img.src = "Images/turrets.png"
  turretSprites = img
  img = new Image()
  img.src = "Images/aliens.png"
  alienSprites = img

  state = title
  bgm.play()

  setup()
  
  render()

render = ->
  context.clearRect 0, 0, canvas.width, canvas.height
  
  context.fillStyle = "white"
  context.fillText "Cash: $" + cash, 300, 10
  
  state()

  requestAnimationFrame render

combat = ->
  done = true
  
  for squadron in squadrons
    if squadron.box[1] < 0 #fall onto screen
      squadron.box[1] += 4
    else    
      squadron.box[0] += squadron.speed
      
      if (squadron.box[0] < 0 and squadron.speed < 0) or (squadron.box[0] + squadron.box[2] > canvas.width and squadron.speed > 0)
        squadron.speed *= -1
        squadron.box[1] += squadron.drop

    if squadron.box[1] + squadron.box[3] > 0 #render
      i = 0
      while i < squadron.length
        switch 
          when squadron.hp[i] <= 1
            sx = 0
          when squadron.hp[i] <= 2
            sx = 1
          when squadron.hp[i] <= 3
            sx = 2
          when squadron.hp[i] <= 50
            sx = 3
          when squadron.hp[i] <= 500
            sx = 4
          else
            sx = 5
          
        context.drawImage alienSprites, sx * 22, 0, 22, 18, squadron.x[i] + squadron.box[0], squadron.y[i] + squadron.box[1], 22, 18
        
        i++
        done = false
    
      #context.fillStyle = "rgba(0, 0, 255, 0.5)"
      #context.fillRect squadron.box[0], squadron.box[1], squadron.box[2], squadron.box[3]
      
    if squadron.box[1] + squadron.box[3] > 350 #collide
      i = squadron.length - 1
      while i >= 0
        if squadron.y[i] + squadron.box[1] > 350
          destroyInvader squadron, i
          destroyTurret random turrets.length
          
          if turrets.length is 0
            state = title
            setup()
            return
        
        i--
        
  drawTurrets()

  i = 0
  while i < shots.length
    shots.x[i] += shots.dx[i]
    shots.y[i] += shots.dy[i]
    shots.timer[i]--
    if shots.timer[i] <= 0
      if shots.id[i] is shotData.scatt
        shell shots.x[i], shots.y[i], -0.7, -0.7, 200, shotData.shell
        shell shots.x[i], shots.y[i], -1,      0, 200, shotData.shell
        shell shots.x[i], shots.y[i], -0.7,  0.7, 200, shotData.shell
        shell shots.x[i], shots.y[i], 0.7,  -0.7, 200, shotData.shell
        shell shots.x[i], shots.y[i], 1,       0, 200, shotData.shell
        shell shots.x[i], shots.y[i], 0.7,   0.7, 200, shotData.shell
        shell shots.x[i], shots.y[i], -0.7, -0.7, 200, shotData.shell
        shell shots.x[i], shots.y[i], 0,      -1, 200, shotData.shell
        shell shots.x[i], shots.y[i], 0,       1, 200, shotData.shell

      explode shots.x[i], shots.y[i], shots.id[i].radius, shots.id[i].power
      createExplosion shots.x[i], shots.y[i], shots.id[i].explosion
      destroyShot i
      
    context.fillRect shots.x[i], shots.y[i], 2, 2
    i++

  i = explosions.length - 1
  while i >= 0
    explosions.timer[i]++
    
    id = explosions.id[i]
    if explosions.timer[i] > id.ticks
      if explosions.frame[i] >= (id.frames[2] * id.frames[3]) - 1
        destroyExplosion i
      else
        explosions.frame[i]++
        explosions.timer[i] = 0
      
    sx = (explosions.frame[i] % id.frames[2]) * id.frames[0]
    sy = parseInt(explosions.frame[i] / id.frames[2]) * id.frames[1]
    context.drawImage explosions.id[i].img, sx, sy, id.frames[0], id.frames[1], explosions.x[i], explosions.y[i], id.frames[0], id.frames[1]
    i--

  i = 0
  while i < 27
    if key.press[i + 65]
      shoot i
    i++
  
  if time < 140 and time % 60 < 30
    context.fillStyle = "white"
    context.fillText "WAVE " + wave, 300, 200
  time++
  
  if done
    bgm.pause() 
    state = intermission
  
intermission = ->
  x = 50
  y = 50
  i = 1
  for name, data of turretData
    if name is "none" then continue
    
    size = 24
    context.drawImage turretSprites, data.frames[0] * 24, data.frames[1] * 28, 24, 24, x + 12, y, 24, 24

    context.fillStyle = "white"
    context.fillText data.name, x, y - 25
    context.fillText "Cost:" + data.cost, x, y - 15
    context.fillText "Power:" + data.shotType.power, x, y - 5
    context.fillText i, x + 20, y + 35
    
    if selection is i
      context.strokeStyle = "white"
      context.lineWidth = 2
      context.strokeRect x - 2, y - 2, 52, 28
      
      if upgradeTarget isnt -1
        if data.cost <= cash and turrets.id[upgradeTarget].cost < data.cost
          turrets.id[upgradeTarget] = data
          upgradeTarget = -1
          cash -= data.cost

    x += 100
    if x > 640
      x = 50
      y += 100
    i++

  context.fillStyle = "white"
  context.fillText "^", 290, 160
  context.fillText "|", 292, 170
  context.fillText "|", 292, 180
  context.fillText "NUMERAL: SELECT UPGRADE", 220, 195
  context.fillText "LETTER: APPLY TO TURRET", 220, 225
  context.fillText "|", 292, 240
  context.fillText "|", 292, 250
  context.fillText "V", 290, 260
  
  context.fillText "SPACE == NEXT WAVE", 520, 455
  
  drawTurrets()
  
drawTurrets = ->
  i = 0
  while i < turrets.length
    
    id = turrets.id[i]
    if id isnt turretData.none
      angle = Math.atan2 mouse.x / 2 - turrets.x[i] - 12, turrets.y[i] + 12 - mouse.y / 2
    else
      angle = 0
    
    context.save()
    context.translate turrets.x[i] + 12, turrets.y[i] + 12
    context.rotate angle
    
    context.drawImage turretSprites, id.frames[0] * 24, id.frames[1] * 28, 24, 24, -12, -12, 24, 24

    context.restore()

    if turrets.cooldown[i] > 0
      multiplier = turrets.cooldown[i] / turrets.id[i].cooldown
      
      context.fillStyle = "rgba(0, 0, 0, 0.75)"
      context.fillRect turrets.x[i] - 8, turrets.y[i] - 8 + 32 * (1 - multiplier), 48 + 16, 32 * multiplier
      
      turrets.cooldown[i]--

    i++

  context.fillStyle = "white"
  
  i = 0
  while i < turrets.x.length
    context.fillText turrets.letter[i], turrets.x[i] + 6, turrets.y[i] + 32
    i++

title = ->
  old = context.font
  
  context.font = "100px sans-serif"
  i = 0
  while i < 4
    context.strokeStyle = ["purple","blue","green","red"][i]
    
    context.strokeText "FACEROLL", 100 - i * 5, 150 - i * 5
    context.strokeText "INVADERS", 100 - i * 5, 250 - i * 5
    
    i++

  context.fillStyle = ["purple","blue","green","red","yellow","pink"][parseInt(time / 5 % 6)]
  time++

  context.fillText "FACEROLL", 100 - i * 5, 150 - i * 5
  context.fillText "INVADERS", 100 - i * 5, 250 - i * 5

  context.font = old
  
  drawTurrets()
  
  context.fillText "AIM: MOUSE", 300, 300
  context.fillText "SHOOT: KEY", 300, 310
  
  context.fillText "Invader sprites by Alfalfamire. Soundtrack ca. FoxSynergy. Explosions by Jetrel and Sinestesia. SFX by krial. Turrets courtesy of Remastered Tyrian Graphics. It's all thanks to these guys!", 300 - time, 460
  
onkeydown = (event) ->
  if event.key == "~"
    squadrons = []
  if event.key == "+"
    cash += 1000000

  if state is combat
    shoot turrets.letter.indexOf event.key.toUpperCase()

  else if state is intermission
    if parseInt(event.key)
      selection = parseInt(event.key)
    
    if selection isnt -1
      letter = turrets.letter.indexOf event.key.toUpperCase()
      
      if letter isnt -1
        upgradeTarget = letter
        
    if event.key == " "
      state = combat
      makeWave()
      selection = -1
      upgradeTarget = -1
      time = 0
      bgm.play()
      
  else if state is title
    time = 0
    state = combat
    makeWave()
      
onmousemove = (event) ->
  mouse.x = event.clientX
  mouse.y = event.clientY
      
shoot = (i) ->
  if i is -1 then return
  if turrets.id[i] is turretData.none then return
  if turrets.cooldown[i] > 0 then return

  turrets.cooldown[i] = turrets.id[i].cooldown
  x = turrets.x[i] + 8
  y = turrets.y[i]
  dx = -(turrets.x[i] - mouse.x / 2)
  dy = -(turrets.y[i] - mouse.y / 2)
  length = Math.sqrt dx * dx + dy * dy
  dx = dx / length * turrets.id[i].shotType.speed
  dy = dy / length * turrets.id[i].shotType.speed
  
  if turrets.id[i].effect is BURST
    shell x, y, dx, dy, length, turrets.id[i].shotType
    
    new Audio("Sound/" + turrets.id[i].sound).play()

  else if turrets.id[i].effect is BEAM
    while x > 0 and x < canvas.width and y > 0 and y < canvas.height
      explode x, y, turrets.id[i].shotType.radius, turrets.id[i].shotType.power
      createExplosion x, y, turrets.id[i].shotType.explosion
      
      x += dx
      y += dy
      
  if turrets.id[i].effect is TRIPLE
    shell x, y, dx, dy, length, turrets.id[i].shotType
    shell x, y, dx - 1, dy, length, turrets.id[i].shotType
    shell x, y, dx + 1, dy, length, turrets.id[i].shotType
    
    new Audio("Sound/" + turrets.id[i].sound).play()

shell = (x, y, dx, dy, range, shot) ->
  shots.x[shots.length] = x
  shots.y[shots.length] = y
  shots.dx[shots.length] = dx
  shots.dy[shots.length] = dy
  
  shots.id[shots.length] = shot
  shots.timer[shots.length] = range / shot.speed
  
  shots.length++

createExplosion = (x, y, type) ->
  explosions.x[explosions.length] = x - type.frames[0] / 2
  explosions.y[explosions.length] = y - type.frames[1] / 2
  explosions.id[explosions.length] = type
  explosions.timer[explosions.length] = 0
  explosions.frame[explosions.length] = 0
  
  new Audio("Sound/" + type.sound).play()
  
  explosions.length++

makeWave = ->
  wave++
  
  step = -100
  for i in [0...wave + 2]
    switch random wave
      when 0
        makeSquadron 0, 10, 5, random(500), step + random(32), 1
      when 1
        makeSquadron 0, 2, 6, random(500), step, 1.4
      when 2
        makeSquadron 0, 2, 2, random(500), step, 1.8
      when 3
        makeSquadron 0, 12, 1, random(500), step, 1.2
      else
        makeSquadron 0, 10, 5, random(500), step, 1

    step -= 1000 - wave * 50

makeSquadron = (type, width, height, dx, dy, speed) ->
  width += random wave
  height += random wave
  dy += random 32
  
  if random(10) < wave
    enhanceSilver = random width
  if wave > 5 and random(50) < wave
    enhanceGold = random width
  if wave > 10 and random(150) < wave
    enhanceDoom = random width
    
  switch type
    when 0
      squadron = { x: [], y: [], hp: [], score: [], box: [0, 0, 32 * width + 16, 32 * height], mode: "shuffle", speed: speed, drop: 32, length: 0 }
      for x in [0...width]
        for y in [0...height]
          squadron.x.push x * 32
          squadron.y.push y * 32
          if y > height - 3
            hp = 1
            score = 5
          else if y > height - 5
            hp = 2
            score = 10
          else
            hp = 3
            score = 15
          
          if enhanceSilver is x
            hp = 15
          if enhanceGold is x
            hp = 100
          if enhanceDoom is x
            hp = 1500
  
          squadron.hp.push hp
          squadron.score.push score
          
          squadron.length++
  
  squadron.box[0] += dx
  squadron.box[1] += dy
  
  if Math.random() < 0.5
    squadron.speed *= -1
  squadron.speed += (Math.random() - 0.5)

  squadrons.push squadron
  
  squadron

setup = ->
  turrets = { x: [], y: [], id: [], cooldown: [], letter: [], length: 0 }
  shots =  { x: [], y: [], dx: [], dy: [], id: [], timer: [], length: 0 }
  explosions =  { x: [], y: [], id: [], timer: [], frame: [], length: 0 }
  squadrons = []
  wave = 0

  for x in [0...10]
    turrets.x.push x * 64 + 16
    turrets.y.push 360
    turrets.id.push turretData.none
    turrets.cooldown.push 0
  for x in [0...9]
    turrets.x.push x * 64 + 32
    turrets.y.push 400
    turrets.id.push turretData.none
    turrets.cooldown.push 0
  for x in [0...7]
    turrets.x.push x * 64 + 56
    turrets.y.push 440
    turrets.id.push turretData.none
    turrets.cooldown.push 0
    
  turrets.letter = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"]
  turrets.length = 26

  turrets.id[4] = turretData.cannon
  turrets.id[19] = turretData.cannon
  turrets.id[25] = turretData.cannon

destroyShot = (i) ->
  shots.x[i] = shots.x[shots.length - 1]
  shots.y[i] = shots.y[shots.length - 1]
  shots.dx[i] = shots.dx[shots.length - 1]
  shots.dy[i] = shots.dy[shots.length - 1]
  shots.id[i] = shots.id[shots.length - 1]
  shots.timer[i] = shots.timer[shots.length - 1]
  
  shots.length--

destroyInvader = (squadron, i) ->
  cash += squadron.score[i]

  squadron.x[i] = squadron.x[squadron.length - 1]
  squadron.y[i] = squadron.y[squadron.length - 1]
  squadron.hp[i] = squadron.hp[squadron.length - 1]
  squadron.score[i] = squadron.score[squadron.length - 1]
  
  squadron.length--

destroyExplosion = (i) ->
  explosions.x[i] = explosions.x[explosions.length - 1]
  explosions.y[i] = explosions.y[explosions.length - 1]
  explosions.id[i] = explosions.id[explosions.length - 1]
  explosions.timer[i] = explosions.timer[explosions.length - 1]
  explosions.frame[i] = explosions.frame[explosions.length - 1]
  
  explosions.length--

destroyTurret = (i) ->
  createExplosion turrets.x[i], turrets.y[i], explosionData.small

  turrets.x[i] = turrets.x[turrets.length - 1]
  turrets.y[i] = turrets.y[turrets.length - 1]
  turrets.id[i] = turrets.id[turrets.length - 1]
  turrets.cooldown[i] = turrets.cooldown[turrets.length - 1]
  turrets.letter[i] = turrets.letter[turrets.length - 1]
  
  turrets.length--

explode = (x, y, radius, power) ->
  for squadron in squadrons
    if overlap squadron, x, y, radius
      hit squadron, x, y, radius, power
          
overlap = (squadron, x, y, radius) ->
  if squadron.box[0] > x + radius or squadron.box[0] + squadron.box[2] < x - radius
    false
  else if squadron.box[1] > y + radius or squadron.box[1] + squadron.box[3] < y - radius
    false
  else
    true
  
hit = (squadron, x, y, radius, power) ->
  radius = Math.pow(radius, 2)
  newBox = [10000, 10000, 0, 0]

  j = squadron.length - 1
  while j >= 0
    dist = Math.pow(squadron.x[j] + squadron.box[0] - x, 2) + Math.pow(squadron.y[j] + squadron.box[1] - y, 2)
    if radius > dist
      squadron.hp[j] -= power
      
      if squadron.hp[j] <= 0
        destroyInvader squadron, j
    
    if squadron.hp[j] > 0
      if squadron.x[j] <= newBox[0] then newBox[0] = squadron.x[j]
      if squadron.y[j] <= newBox[1] then newBox[1] = squadron.y[j]
      if squadron.x[j] >= newBox[2] then newBox[2] = squadron.x[j]
      if squadron.y[j] >= newBox[3] then newBox[3] = squadron.y[j]
    
    j--

  j = squadron.length - 1
  while j >= 0
    squadron.x[j] -= newBox[0]
    squadron.y[j] -= newBox[1]
    
    j--
  
  newBox[0] += squadron.box[0]
  newBox[1] += squadron.box[1]
  newBox[2] += 16
  newBox[3] += 16
  console.log newBox
  
  squadron.box = newBox
  
random = (max) ->
  parseInt(Math.random() * max)
  