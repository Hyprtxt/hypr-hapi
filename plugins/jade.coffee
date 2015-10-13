exports.register = ( server, options, next ) ->

  server.expose 'global', ( request, reply ) ->
    request.pre = require '../view-data/global'
    return reply()

  return next()

exports.register.attributes =
  name: 'jade'
  version: '0.1.0'
