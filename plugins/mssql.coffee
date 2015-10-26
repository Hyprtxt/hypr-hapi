TDS = require('tedious')
Connection = TDS.Connection;
Request = TDS.Request;

exports.register = ( server, options, next ) ->
  config =
    userName: 'TaylorTest'
    password: 'pa55word'
    server: '10.50.50.104'
    options:
      rowCollectionOnDone: true
      # useColumnNames: true

  conn = new Connection config
  server.expose 'connection', conn
  conn.on 'connect', ( err ) ->
    if err
      throw err
    else
      console.log 'connected to MSSQL'
      server.expose 'Request', Request
      # conn.execSql request

  next()
  return

exports.register.attributes =
  name: 'mssql'
  version: '0.1.0'
