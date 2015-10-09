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
    cors: true
    handler: ( request, reply ) ->
      return reply 'hello world'

server.start ->
  return console.log 'Server started at: ', server.info.uri
