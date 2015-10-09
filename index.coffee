Hapi = require 'hapi'
Yar = require 'yar'
Request = require 'request'

server = new Hapi.Server()

server.connection require('./config').get('/connection')

server.register require('./config').get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.route
  method: 'GET'
  path: '/'
  config:
    handler: ( request, reply ) ->
      request.session.set 'cookie', key: 'VALUESSS'
      return reply 'hello world'

authCB = ( request, reply ) ->
  request.session.set request.params.provider, request.query
  cookie = JSON.stringify request.session.get 'cookie'
  return reply 'login success?' + cookie

server.route
  method: 'GET'
  path: '/{provider}/callback'
  config:
    handler: authCB

server.start ->
  return console.log 'Server started at: ', server.info.uri
