exports.register = ( server, options, next ) ->

  io = require('socket.io')( server.listener )

  io.use ( socket, next ) ->
    console.log socket.handshake.query
    return next();

  io.on 'connection', ( socket ) ->
    socket.emit 'message',
      message: 'server messages present'
      type: 'success'
    socket
      .on 'disconnect', ->
        console.log socket.id + ' disconnected'
        return null
    return null

  server.app.io = io

  next()
  return

exports.register.attributes =
  name: 'sockets'
  version: '0.1.0'
