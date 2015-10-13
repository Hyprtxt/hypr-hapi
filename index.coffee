Hapi = require 'hapi'
Request = require 'request'

config = require './config'

server = new Hapi.Server()

server.connection config.get '/connection'

server.register config.get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.auth.strategy

server.views config.get('/view')

server.route
  method: 'GET'
  path: '/'
  config:
    pre: [ server.plugins['jade'].global ]
    handler: ( request, reply ) ->
      request.pre.facebook = request.session.get 'facebook'
      request.pre.acton = request.session.get 'acton'
      return reply.view 'index', request.pre

server.route
  method: 'GET'
  path: '/readme'
  config:
    pre: [ server.plugins['jade'].global ]
    handler: ( request, reply ) ->
      return reply.view 'readme', request.pre

server.route
  method: 'GET'
  path: '/{provider}/callback'
  config:
    handler: ( request, reply ) ->
      console.log request.query, 'QUERY'
      grant = request.session.get 'grant'
      request.session.set grant.provider, grant.response.raw
      return reply.redirect '/'

server.route
  method: [ 'GET' ]
  path: '/realtime'
  config:
    handler: ( request, reply ) ->
      console.log request.query
      return reply( request.query.hub.challenge )

server.route
  method: [ 'POST' ]
  path: '/realtime'
  config:
    payload:
      output: 'data'
    handler: ( request, reply ) ->
      console.log request.payload
      return reply( request.payload.hub.challenge )

server.start ->
  return console.log 'Server started at: ', server.info.uri
