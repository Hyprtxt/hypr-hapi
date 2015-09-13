exports.register = ( server, options, next ) ->
  io = require('socket.io')(server.listener)

  io.on 'connection', ( socket ) ->

    # console.log socket
    console.log socket.id

    socket
      .emit 'news', hello: 'world man'
      .on 'client_event', ( data ) ->
        console.log data, 'from', socket.id
        return
      .on 'disconnect', ->
        console.log socket.id + ' disconnected'
        return
    return

  next()
  return

exports.register.attributes =
  name: 'sockets'
  version: '0.1.0'
