Hapi = require 'hapi'
Request = require 'request'

server = new Hapi.Server()

server.connection
  host: 'gulp.hyprtxt.dev'
  port: 8080

server.route
  method: 'GET'
  path: '/api'
  config:
    cors: true
    handler: ( request, reply ) ->
      beerRun =
        url: 'http://beer.fluentcloud.com/v1/beer'
      return Request.get beerRun, ( error, response, body ) ->
        return reply JSON.parse body

server.route
  method: 'PUT'
  path: '/api/{id}'
  config:
    cors: true
    payload:
      output: 'data'
      parse: true
    handler: ( request, reply ) ->
      console.log request.payload
      beerRun =
        method: 'PUT'
        uri: 'http://beer.fluentcloud.com/v1/beer/' + request.params.id
        json: true
        body: request.payload
      return Request beerRun, ( error, response, body ) ->
        if error
          throw error
        return reply response.statusCode

server.route
  method: 'DELETE'
  path: '/api/{id}'
  config:
    cors: true
    payload:
      output: 'data'
      parse: true
    handler: ( request, reply ) ->
      console.log request.payload
      beerRun =
        method: 'DELETE'
        uri: 'http://beer.fluentcloud.com/v1/beer/' + request.params.id
      return Request beerRun, ( error, response, body ) ->
        if error
          throw error
        return reply response.statusCode

server.start ->
  console.log 'Server started at: ', server.info.uri
