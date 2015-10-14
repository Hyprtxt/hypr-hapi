Hapi = require 'hapi'
Request = require 'request'

config = require './config'

server = new Hapi.Server config.get '/server'

server.connection config.get '/connection'

server.register config.get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.views config.get '/view'

getFacebookAccessToken = ( next ) ->
  console.log 'Getting FaceBook Access Token'
  fbConfig = config.get '/facebook'
  opts =
    method: 'POST'
    baseUrl: 'https://graph.facebook.com'
    url: '/oauth/access_token'
    json: true
    formData:
      client_id: fbConfig.client_id
      client_secret: fbConfig.client_secret
      grant_type: 'client_credentials'
  Request opts, ( err, resp, body ) ->
    if !err && resp.statusCode is 200
      fbConfig.access_token = body.replace 'access_token=', ''
      return next null, fbConfig

server.method 'facebook_token', getFacebookAccessToken,
  cache:
    expiresIn: 3000 * 1000
    generateTimeout: 1000

getActOnAccessToken = ( next ) ->
  console.log 'Getting ActOn Access Token'
  actConfig = config.get '/acton'
  actConfig.grant_type = 'password'
  opts =
    method: 'POST'
    baseUrl: 'https://graph.facebook.com'
    url: '/oauth/access_token'
    json: true
    formData: actConfig
  Request opts, ( err, resp, body ) ->
    if !err && resp.statusCode is 200
      console.log body
      return next null, body

server.method 'acton_token', getActOnAccessToken,
  cache:
    expiresIn: 3500 * 1000
    generateTimeout: 1000

# setupActon = ->
#   server.methods.acton_token ( err, acton ) ->
#     return

setupFacebookSubscriptionCallback = ->
  server.methods.facebook_token ( err, fb ) ->
    opts =
      url: '/v2.5/' + fb.client_id + '/subscriptions'
      baseUrl: 'https://graph.facebook.com'
      method: 'POST'
      json: true
      formData:
        object: 'page'
        callback_url: 'https://tunnel.hyprtxt.com/realtime'
        fields: 'leadgen'
        access_token: fb.access_token
        verify_token: 'verify1234'
    Request opts, ( err, resp, body ) ->
      if body.success is true
        console.log 'subscription callback setup success'
      else
        console.log 'subscription setup failure', body
      return

setupFacebookSubscriptionCallback()

server.route
  method: 'GET'
  path: '/cache'
  config:
    pre: [ server.plugins['jade'].global ]
    handler: ( request, reply ) ->
      server.methods.facebook_token ( err, fb ) ->
        request.pre.cache = fb
        return reply.view 'cache', request.pre
      return

server.route
  method: 'GET'
  path: '/'
  config:
    pre: [ server.plugins['jade'].global ]
    handler: ( request, reply ) ->
      request.pre.facebook = request.session.get 'facebook'
      request.pre.acton = request.session.get 'acton'
      return server.methods.facebook_token ( err, act ) ->
        request.pre.act = act
        return server.methods.facebook_token ( err, fb ) ->
          request.pre.fb = fb
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
      return server.methods.facebook_token ( err, fb ) ->
        opts =
          method: 'GET'
          json: true
          baseUrl: 'https://graph.facebook.com'
          url: '/v2.5/subscriptions'
          qs:
            access_token: fb.access_token
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
