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
      DBRequest = server.plugins.mssql.Request
      sql = "SELECT TOP 1000 * FROM [Test].[dbo].[test_table]"
      request.pre.rows = []
      dbRequest = new DBRequest sql, ( err, rowCount ) ->
        if err
          throw err
        else
          console.log rowCount + 'rows'
          return reply.view 'index', request.pre
      dbRequest.on 'row', ( columns ) ->
        request.pre.rows.push columns
        return null
      server.plugins.mssql.connection.execSql dbRequest


server.start ->
  return console.log 'Server running at:', server.info.uri
