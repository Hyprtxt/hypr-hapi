Messenger.options =
  extraClasses: 'messenger-fixed messenger-on-bottom'
  theme: 'air'

$halt = $ '#halt'
$export = $ '#export'

socket = io '/'

socket
  .on 'connect', ->
    Messenger().post
      message: 'Realtime messaging connected with ID: ' + socket.io.engine.id
      type: 'success'
      showCloseButton: true
    socket.emit 'link', { data: 'good' }
    return null
  .on 'message', ( data ) ->
    data.showCloseButton = true
    Messenger().post data
    return null
  .on 'disconnect', ->
    Messenger().post
      message: 'I lost contact with the server, something\'s gone horribly wrong'
      type: 'error'
    setTimeout ->
      window.location = '/'
    , 5000
    return null

$halt.on 'click', ->
  socket.emit 'halt_export'
  return null

$export.on 'click', ( e ) ->
  e.preventDefault()
  $( 'form' ).slideUp()
  $.ajax( '/export/' + $( '#leadStart' ).val() )
  return null
