gpio = require 'rpi-gpio'
async = require 'async'

delay = 5

delayedWrite = ( pin, value, done ) ->
  gpio.write pin, value, ->
    setTimeout ->
      done()
      return
    , delay
    return
  return

blink = ( pin, done ) ->
  delayedWrite pin, true, ->
    setTimeout ->
      delayedWrite pin, false, ->
        done()
        return
      return
    , 200
    return

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
      socket.emit 'button',
        channel: channel
        value: value
      if channel is 40
        delayedWrite 33, value, ->
      if channel is 38
        delayedWrite 35, value, ->
      if channel is 36
        delayedWrite 37, value, ->
      return
    socket
      .on 'link', ( data ) ->
        console.log data
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
