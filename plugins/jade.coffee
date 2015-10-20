Request = require 'request'

exports.register = ( server, options, next ) ->

  server.expose 'global', ( request, reply ) ->
    request.pre = require '../view-data/global'
    return reply()

  server.expose 'facebook', ( request, reply ) ->
    server.methods.facebook_token ( err, fb ) ->
      request.pre.fb = fb
      return reply()
    return

  server.expose 'acton', ( request, reply ) ->
    server.methods.acton_token ( err, act ) ->
      request.pre.act = act
      return reply()
    return

  return next()

exports.register.attributes =
  name: 'jade'
  version: '0.1.0'
