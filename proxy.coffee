Hapi = require 'hapi'
Request = require 'request'

server = new Hapi.Server()

server.connection
  host: 'localhost'
  port: 8080

server.route
  method: 'GET'
  path: '/'
  config:
    cors: true
    handler: ( request, reply ) ->
      beerRun =
        url: 'http://beer.fluentcloud.com/v1/beer'
      return Request.get beerRun, ( error, response, body ) ->
        return reply JSON.parse body

server.start ->
  console.log 'Server started at: ', server.info.uri
