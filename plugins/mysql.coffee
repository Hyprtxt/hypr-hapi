Mysql = require 'mysql'

exports.register = ( server, options, next ) ->
  pool = Mysql.createPool require('../config/database').get '/mysql'
  pool.getConnection ( err ) ->
    if !err
      server.log [ 'success', 'database', 'connection' ], "MySQL DB Connected"
    else
      server.log [ 'error', 'database', 'connection' ], err
  server.expose 'pool', pool
  server.expose 'query', ( query, callback = -> ) ->
    server.plugins['mysql'].pool.getConnection ( err, connection ) ->
      if err
        connection.release()
        server.log [ 'error', 'database', 'connection' ], err
        return
      query = connection.query query, ( err, rows ) ->
        connection.release()
        if err
          server.log [ 'error', 'database', 'query' ], err
          console.log 'BAD QUERY: ', query.sql
        callback rows
        return
      return
    return

  next()
  return

exports.register.attributes =
  name: 'mysql'
  version: '0.1.0'
