key = { press: [], down: [], up: [] }
mouse = { press: [], down: [], up: [], position: {x:0, y:0}, move: {x:0, y:0} }

setupKeys = (canvas) ->
  document.addEventListener "keydown", (event) ->
    if not key.press[event.keyCode]
      key.press[event.keyCode] = true
      
    key.down[event.keyCode] = true

  document.addEventListener "keyup", (event) ->
    key.down[event.keyCode] = false

  document.addEventListener "blur", (event) ->
    key.down.length = 0

  canvas.addEventListener "mousedown", (event) ->
    if not mouse.press[event.button]
      mouse.press[event.button] = true
      
    mouse.down[event.button] = true
    
    if event.target.setCapture
      event.target.setCapture()
    
    event.preventDefault()

  canvas.addEventListener "mouseup", (event) ->
    mouse.down[event.button] = false
    
    event.preventDefault()
    return false
      
  canvas.addEventListener "mousemove", (event) ->
    mouse.position.x = event.clientX
    mouse.position.y = event.clientY

    mouse.move.x += event.movementX or event.mozMovementX or event.webkitMovementX or 0
    mouse.move.y += event.movementY or event.mozMovementY or event.webkitMovementY or 0
      
  canvas.addEventListener "contextmenu", (event) ->
    event.preventDefault()
    
clearKeysPressed = ->
  for k of key.press
    key.press[k] = false
    
  for b of mouse.press
    mouse.press[b] = false
    
  mouse.move.x = 0
  mouse.move.y = 0
