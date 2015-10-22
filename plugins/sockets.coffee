exports.register = ( server, options, next ) ->

  io = require('socket.io')( server.listener )

  io.use ( socket, next ) ->
    console.log socket.handshake.query
    return next();

  io.on 'connection', ( socket ) ->
    socket
      .on 'link', ( data ) ->
        console.log data
        socket.emit 'cards', 'DATA HERE'
        return null
      .on 'disconnect', ->
        console.log socket.id + ' disconnected'
        return null
    return null

  next()
  return

exports.register.attributes =
  name: 'sockets'
  version: '0.1.0'
