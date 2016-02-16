console.log 'script loaded'
socket = io()

$btns = $ '.btn'

$btns.on 'click', ( e ) ->
  socket.emit 'link',
    button: e.target.id


socket.on 'status', ( data ) ->
  console.log data
  return
