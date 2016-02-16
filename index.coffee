Hapi = require 'hapi'

server = new Hapi.Server()

server.connection require('./config').get '/connection'

server.register require('./config').get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.views require('./config').get '/view'

# Homepage
server.route
  method: 'GET'
  path: '/'
  config:
    pre: [ server.plugins['jade'].global ]
    handler: ( request, reply ) ->
      reply.view 'index', request.pre
      return

server.start ->
  return console.log 'Server running at:', server.info.uri
