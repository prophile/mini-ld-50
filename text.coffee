World =
  pos: Level.config.start_location
  health: Level.config.start_health
  taken: _.object([place, []] for place in _.keys(Level.places))
  kills: 0

noMoreOutput = false

underFire = ->
  for obj in objectsHere()
    if Level.objects[obj].damage > 0
      dmg = Level.objects[obj].damage
      if Math.random() < 0.8
        addOutput("The #{Level.objects[obj].name} hits you for #{dmg} damage.")
        World.health -= dmg
        if World.health <= 0
          addOutput("You are dead. You finished with #{World.kills} kills.")
          $('#command').attr('disabled', 'disabled')
          noMoreOutput = true

objectsHere = ->
  _.difference(Level.places[World.pos].objects, World.taken[World.pos])

printStatusLine = ->
  addOutput("You have #{World.kills} kills and #{World.health} health.")

dispatchShoot = ->
  for obj in objectsHere()
    if Level.objects[obj].health > 0
      probKill = Level.config.weapon_damage / Level.objects[obj].health
      if Math.random() < probKill
        addOutput("You kill the #{Level.objects[obj].name}.")
        World.kills += 1
        World.taken[World.pos].push obj
        printStatusLine()
      else
        addOutput("You hit the #{Level.objects[obj].name} for #{Level.config.weapon_damage} damage.")
      underFire()
      return
  addOutput("You find nothing to shoot.")

dispatchTake = ->
  for obj in objectsHere()
    if Level.objects[obj].heals > 0
      World.health += Level.objects[obj].heals
      World.taken[World.pos].push obj
      clearOutput()
      addOutput("You take the #{Level.objects[obj].name}.")
      dispatchLookAround(true)
      return
  addOutput("There is nothing to take.")

addOutput = (output) ->
  $('#output').append($('<p>').text(output)) unless noMoreOutput

clearOutput = ->
  $('#output').empty()

dispatchLookAround = (takeFire = false) ->
  addOutput(Level.places[World.pos].text)
  for obj in objectsHere()
    addOutput("There is a #{Level.objects[obj].name}.")
  underFire() if takeFire
  printStatusLine()

dispatchGo = (target) ->
  tgt = Level.places[World.pos].connections[target]
  if tgt?
    World.pos = tgt
    clearOutput()
    dispatchLookAround(true)
  else
    addOutput("Where?")

dispatchHelp = ->
  addOutput('go <direction>')
  addOutput('shoot <object>')
  addOutput('look at <object>')
  addOutput('take <object>')
  addOutput('look')

dispatchCommand = (command) ->
  components = command.toLowerCase().split(' ')
  return unless components.length > 0
  verb = components[0]
  if verb is 'help'
    dispatchHelp()
    $('#command').attr('placeholder', 'look')
  else if verb is 'clear'
    clearOutput()
    dispatchLookAround()
  else if verb is 'look' and components.length is 1
    dispatchLookAround()
  else if verb is 'take'
    dispatchTake()
  else if verb is 'go' and components.length is 2
    dispatchGo(components[1])
  else if verb is 'shoot'
    dispatchShoot()
  else
    dispatchHelp()

$ ->
  $('#command').focus()
  $('#command-form').submit (event) ->
    $('#command').blur()
    _.defer ->
      $('#command').val('')
      $('#command').focus()
    event.preventDefault()
    dispatchCommand $('#command').val()
    false
  dispatchLookAround()

