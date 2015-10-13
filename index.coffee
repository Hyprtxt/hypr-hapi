Hapi = require 'hapi'
Yar = require 'yar'
Request = require 'request'

server = new Hapi.Server()

server.connection require('./config').get('/connection')

server.register require('./config').get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.views require('./config').get('/view')

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
      console.log request.query
      request.session.set request.params.provider, request.query.raw
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

# Static
server.route
  method: 'GET'
  path: '/{param*}'
  handler:
    directory:
      path: [
        './static/'
        './static_generated/'
      ]
      redirectToSlash: true
      listing: true

server.start ->
  return console.log 'Server started at: ', server.info.uri
