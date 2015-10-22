console.log 'script loaded'

socket = io '/'

socket
  .on 'connect', (  ) ->
    console.log 'connected, ID:' + socket.io.engine.id
    return socket.emit 'link', { data: 'good' }
  .on 'link_complete', ->
    return console.log 'link_complete'
  .on 'disconnect', ->
    console.log 'disconnected'
    return setTimeout ->
      window.location = '/'
    , 3000
