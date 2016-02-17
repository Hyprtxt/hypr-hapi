console.log 'script loaded'
socket = io()

$btns = $ '.input'
$lights = $ '.output'

getPins = ( btnID ) ->
  console.log 'ID', btnID
  number = btnID.replace 'btn', ''
  if number is '1'
    return 37
  if number is '2'
    return 35
  if number is '3'
    return 33
  if number is '4'
    return 31
  if number is '5'
    return 29
  if number is '6'
    return 32

$btns.on 'mousedown', ( e ) ->
  console.log getPins e.target.id
  socket.emit 'link',
    button: e.target.id
    value: true
    pin: getPins e.target.id
  return

$btns.on 'mouseup', ( e ) ->
  socket.emit 'link',
    button: e.target.id
    value: false
    pin: getPins e.target.id
  return

socket.on 'status', ( data ) ->
  console.log data
  return

socket.on 'button', ( data ) ->
  console.log data
  $light = $ '#light' + data.channel
  if data.value
    $light.addClass 'active'
  else
    $light.removeClass 'active'
  return
