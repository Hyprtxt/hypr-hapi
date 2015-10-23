Messenger.options =
  extraClasses: 'messenger-fixed messenger-on-top'
  theme: 'air'

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
    , 3000
    return null
