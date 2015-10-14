Request = require 'request'

exports.register = ( server, options, next ) ->

  server.expose 'global', ( request, reply ) ->
    request.pre = require '../view-data/global'
    return reply()

  server.expose 'facebook', ( request, reply ) ->
    return reply()

  server.expose 'acton', ( request, reply ) ->
    acton = request.session.get 'acton'
    if acton is undefined
      return reply 'Please authorize the application with your Act-On account'
    now = parseInt Date.now() / 1000
    if now > acton.expiration
      console.log 'Refreshing Acton Token'
      data =
        refresh_token: acton.refresh_token
        grant_type: 'refresh_token'
        client_id: 'Drqi8At9LgrlHQUP4S6a6rEJrDIa'
        client_secret: '_TifPts48nGDvcqZgXvQ6cY63Swa'
      opts =
        url: 'token'
        baseUrl: 'https://restapi.actonsoftware.com'
        method: 'POST'
        json: true
        form: data
      Request opts, ( err, resp, body ) ->
        session = body
        now = parseInt Date.now() / 1000
        session.origin_time = now
        session.expiration = parseInt( now - 60 ) + parseInt grant.response.raw.expires_in
        request.session.set 'acton', session
        request.pre.acton = session
        return reply()
    else
      # valid
      request.pre.acton = acton
      return reply()

  return next()

exports.register.attributes =
  name: 'jade'
  version: '0.1.0'
