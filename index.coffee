Hapi = require 'hapi'
Request = require 'request'

fb =
  client_id: '1513710378927269'
  client_secret: 'b7741bad6244c28f34d6bdc2e9116def'
data =
  client_id: fb.client_id
  client_secret: fb.client_secret
  grant_type: 'client_credentials'
opts =
  url: '/oauth/access_token'
  baseUrl: 'https://graph.facebook.com'
  method: 'POST'
  formData: data
  json: true

Request opts, ( err, resp, body ) ->
  fb.access_token = body.replace 'access_token=', ''
  console.log 'FB', fb
  setupSubscription()
  return

setupSubscription = ->
  data =
    object: 'page'
    callback_url: 'https://tunnel.hyprtxt.com/realtime'
    fields: 'leadgen'
    access_token: fb.access_token
    verify_token: 'verify1234'
  opts =
    url: '/v2.5/' + fb.client_id + '/subscriptions'
    baseUrl: 'https://graph.facebook.com'
    method: 'POST'
    formData: data
    json: true
  Request opts, ( err, resp, body ) ->
    if body.success is true
      console.log 'subscription callback setup success'
    else
      console.log 'subscription setup failure', body
    return


config = require './config'

server = new Hapi.Server config.get '/server'

server.connection config.get '/connection'

server.register config.get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.views config.get '/view'

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
  path: '/facebook/subscriptions'
  config:
    pre: [
      server.plugins['jade'].global
    ]
    handler: ( request, reply ) ->
      opts =
        baseUrl: 'https://graph.facebook.com'
        url: '/v2.5/subscriptions'
        qs:
          access_token: fb.access_token
        method: 'GET'
        json: true
      return Request opts, ( err, resp, body ) ->
        request.pre.subs = body.data
        return reply.view 'subscriptions', request.pre

server.route
  method: 'GET'
  path: '/acton/lists'
  config:
    pre: [
      server.plugins['jade'].global
      server.plugins['jade'].acton
    ]
    handler: ( request, reply ) ->
      if request.pre.acton is undefined
        return reply 'Auth with Act-On first'
      else
        opts =
          url: '/api/1/list'
          baseUrl: 'https://restapi.actonsoftware.com'
          method: 'GET'
          json: true
        return Request opts, ( err, resp, body ) ->
          request.pre.lists = body
          return reply.view 'lists', request.pre
        .auth null, null, true, request.pre.acton.access_token

server.route
  method: 'GET'
  path: '/{provider}/callback'
  config:
    handler: ( request, reply ) ->
      console.log request.query, 'QUERY'
      grant = request.session.get 'grant'
      session = grant.response.raw
      now = parseInt Date.now() / 1000
      session.origin_time = now
      if grant.provider is 'acton'
        session.expiration = parseInt( now - 60 ) + parseInt grant.response.raw.expires_in
      else # facebook
        session.expiration = parseInt( now - 60 ) + parseInt grant.response.raw.expires
      request.session.set grant.provider, session
      return reply.redirect '/'

server.route
  method: 'GET'
  path: '/realtime'
  config:
    handler: ( request, reply ) ->
      console.log request.query
      if request.query.hub is undefined
        return reply().code 404
      if request.query.hub.mode is 'subscribe'
        return reply request.query.hub.challenge
      else
        return reply().code 400


server.route
  method: 'POST'
  path: '/realtime'
  config:
    payload:
      output: 'data'
    handler: ( request, reply ) ->
      console.log 'Recieved PING~'
      console.log ''
      console.log request.payload
      console.log ''
      console.log '~PING'
      return reply()

server.start ->
  return console.log 'Server started at: ', server.info.uri
