gpio = require 'rpi-gpio'
async = require 'async'

gpio.setup 40, gpio.DIR_IN, gpio.EDGE_BOTH
gpio.setup 38, gpio.DIR_IN, gpio.EDGE_BOTH
gpio.setup 36, gpio.DIR_IN, gpio.EDGE_BOTH

async.parallel [
  ( callback ) ->
    gpio.setup 37, gpio.DIR_OUT, callback
    return
  ( callback ) ->
    gpio.setup 35, gpio.DIR_OUT, callback
    return
  ( callback ) ->
    gpio.setup 33, gpio.DIR_OUT, callback
    return
  ( callback ) ->
    gpio.setup 31, gpio.DIR_OUT, callback
    return
  ( callback ) ->
    gpio.setup 29, gpio.DIR_OUT, callback
    return
  ( callback ) ->
    gpio.setup 32, gpio.DIR_OUT, callback
    return
], ( err, results ) ->
  console.log 'Output Pins set up'
  return



exports.register = ( server, options, next ) ->
  # cache = server.cache
  #   expiresIn: 1 * 24 * 3600 * 1000 # 1 day
  #
  # server.app.cache = cache
  #
  # server.bind
  #   cache: server.app.cache

  io = require('socket.io')(server.listener)

  io.use ( socket, next ) ->
    console.log socket.handshake.query
    return next();

  io.on 'connection', ( socket ) ->
    gpio.on 'change', ( channel, value ) ->
      console.log channel, value
      socket.emit 'button',
        channel: channel
        value: value
      return
    socket
      .on 'link', ( data ) ->
        console.log data
        gpio.write data.pin, data.value, ->
          return
        socket.emit 'status',  status: 'good'
        return
      .on 'disconnect', ->
        console.log socket.id + ' disconnected'
        return

  next()
  return

exports.register.attributes =
  name: 'sockets'
  version: '0.1.0'
