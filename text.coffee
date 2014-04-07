World =
  pos: Level.config.start_location
  health: Level.config.start_health
  taken: _.object([place, []] for place in _.keys(Level.places))
  kills: 0

addOutput = (output) ->
  $('#output').append($('<p>').text(output))

clearOutput = ->
  $('#output').empty()

dispatchLookAround = ->
  addOutput(Level.places[World.pos].text)
  addOutput("You have #{World.kills} kills and #{World.health} health.")

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

