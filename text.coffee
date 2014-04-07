World =
  pos: Level.config.start_location
  health: Level.config.start_health
  taken: _.object([place, []] for place in _.keys(Level.places))
  kills: 0
  weapon: Level.config.start_weapon

noMoreOutput = false

endGame = ->
  $('#command').attr('disabled', 'disabled')
  addOutput("<em>A game by Taylor Vaughan and Alistair Lynn.</em>")
  noMoreOutput = true

underFire = ->
  for obj in objectsHere()
    if Level.objects[obj].damage > 0
      dmg = Level.objects[obj].damage
      if Math.random() < (1 - Level.config.dodge_chance)
        addOutput("The #{Level.objects[obj].name} hits you for #{dmg} damage.")
        World.health -= dmg
        if World.health <= 0
          addOutput("You are dead. You finished with #{World.kills} kills.")
          endGame()

objectsHere = ->
  objs = _.clone Level.places[World.pos].objects
  for dropped in World.taken[World.pos]
    index = objs.indexOf dropped
    if index > -1
      objs.splice index, 1
  objs

printStatusLine = ->
  addOutput("You have #{World.kills} kills and #{World.health} health.")

isMatch = (obj, name) ->
  return true unless name?
  aliases = Level.objects[obj].aliases ? obj
  for alias in aliases
    if name is alias
      return true
  return false

dispatchShoot = (target) ->
  console.log(objectsHere())
  for obj in objectsHere()
    continue unless isMatch(obj, target)
    if Level.objects[obj].health > 0
      [weaponDamage, weaponReload] = World.weapon
      probKill = weaponDamage / Level.objects[obj].health
      if Math.random() < probKill
        addOutput("You kill the #{Level.objects[obj].name}.")
        World.kills += 1
        World.taken[World.pos].push obj
        if World.kills >= Level.config.required_kills
          addOutput("Congratulations! You have caused the requisite quantity of havoc!")
          endGame()

        printStatusLine()
      else
        addOutput("You hit the #{Level.objects[obj].name} for #{weaponDamage} damage.")
      if Math.random() < (1 / weaponReload)
        addOutput("You reload your weapon.")
      underFire()
      return
  addOutput("You find nothing to shoot.")

dispatchTake = (target) ->
  for obj in objectsHere()
    continue unless isMatch(obj, target)
    taken = false
    if Level.objects[obj].heals > 0
      World.health += Level.objects[obj].heals
      taken = true
    else if Level.objects[obj].weapon?
      World.weapon = Level.objects[obj].weapon
      taken = true
    if taken
      World.taken[World.pos].push obj
      addOutput("You take the #{Level.objects[obj].name}.")
      dispatchLookAround(true)
      return
  addOutput("There is nothing to take.")

addOutput = (output) ->
  $('#output').append($('<p>').html(output)) unless noMoreOutput

clearOutput = ->
  $('#output').empty()

dispatchLookAround = (takeFire = false) ->
  addOutput(Level.places[World.pos].text)
  for obj in objectsHere()
    addOutput("There is a #{Level.objects[obj].name}.")
  underFire() if takeFire
  printStatusLine()

dispatchLookAt = (target) ->
  for obj in objectsHere()
    continue unless isMatch(obj, target)
    addOutput(Level.objects[obj].long)

dispatchGo = (target) ->
  tgt = Level.places[World.pos].connections[target]
  if tgt?
    World.pos = tgt
    clearOutput()
    dispatchLookAround(true)
  else
    addOutput("Where?")

dispatchHelp = ->
  addOutput('Commands:')
  addOutput('go <em>direction</em>')
  addOutput('shoot <em>object</em>')
  addOutput('look at <em>object</em>')
  addOutput('take <em>object</em>')
  addOutput('look')

dispatchCommand = (command) ->
  components = command.toLowerCase().split(' ')
  return unless components.length > 0
  verb = components[0]
  outputObj = $('<pre>').text('> ' + command)
  $('#output').append(outputObj)
  if verb is 'help'
    dispatchHelp()
    $('#command').attr('placeholder', 'look')
  else if verb is 'clear'
    clearOutput()
    dispatchLookAround()
  else if verb is 'look' and components.length is 1
    dispatchLookAround()
  else if verb is 'look' and components[1] is 'at'
    dispatchLookAt(components[2])
  else if verb is 'take' or verb is 'get'
    dispatchTake(components[1])
  else if verb is 'go' and components.length is 2
    dispatchGo(components[1])
  else if verb in ['shoot', 'kill', 'attack']
    dispatchShoot(components[1])
  else
    if verb in _.keys(Level.places[World.pos].connections)
      dispatchGo(verb)
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

