Hapi = require 'hapi'
Request = require 'request'
Async = require 'async'

config = require './config'

server = new Hapi.Server config.get '/server'

fbPageId = '50318073949'

server.connection config.get '/connection'

server.register config.get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.views config.get '/view'

server.auth.scheme 'simple', ( server, options ) ->
  scheme = {}
  scheme.authenticate = ( request, reply ) ->
    facebook = request.session.get('facebook')
    if facebook
      result =
        credentials:
          facebook: facebook
      reply.continue result
    else
      reply 'Please Login with Facebook first'
  return scheme
server.auth.strategy 'facebook', 'simple'

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
    baseUrl: 'https://restapi.actonsoftware.com'
    url: '/token'
    json: true
    form: actConfig
  Request opts, ( err, resp, body ) ->
    if !err && resp.statusCode is 200
      return next null, body
    else
      console.log err, resp.statusCode, body

server.method 'acton_token', getActOnAccessToken,
  cache:
    expiresIn: 3500 * 1000
    generateTimeout: 1000

# setupActon = ->
#   server.methods.acton_token ( err, acton ) ->
#     return null
#   return null
#
# setupActon()

# setupFacebookSubscriptionCallback = ->
#   server.methods.facebook_token ( err, fb ) ->
#     opts =
#       url: '/v2.5/' + fb.client_id + '/subscriptions'
#       baseUrl: 'https://graph.facebook.com'
#       method: 'POST'
#       json: true
#       formData:
#         object: 'page'
#         callback_url: 'https://tunnel.hyprtxt.com/realtime'
#         fields: 'leadgen'
#         access_token: fb.access_token
#         verify_token: 'verify1234'
#     Request opts, ( err, resp, body ) ->
#       if body.success is true
#         console.log 'subscription callback setup success'
#       else
#         console.log 'subscription setup failure', body
#       return
#
# setupFacebookSubscriptionCallback()

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
    pre: [
      server.plugins['jade'].global
      server.plugins['jade'].facebook
      server.plugins['jade'].acton
    ]
    handler: ( request, reply ) ->
      request.pre.facebook = request.session.get 'facebook'
      request.pre.acton = request.session.get 'acton'
      return reply.view 'index', request.pre

server.route
  method: 'GET'
  path: '/readme'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
    ]
    handler: ( request, reply ) ->
      server.app.io.sockets.emit 'message',
        message: 'this is just a test'
        type: 'success'
      return reply.view 'readme', request.pre

server.route
  method: 'GET'
  path: '/fb/leadgen_forms'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
    ]
    handler: ( request, reply ) ->
      opts =
        method: 'GET'
        json: true
        baseUrl: 'https://graph.facebook.com'
        url: '/v2.5/' + fbPageId + '/leadgen_forms'
        qs:
          access_token: request.auth.credentials.facebook.access_token
      Request opts, ( err, resp, body ) ->
        console.log body
        request.pre.forms = body.data
        reply.view 'forms', request.pre
        return null
      return null

# _leadData = []

server.route
  method: 'GET'
  path: '/fb/{formid}'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
      server.plugins['facebook'].getAllLeads
    ]
    handler: ( request, reply ) ->
      reply.view 'leads', request.pre
      return null

server.route
  method: 'GET'
  path: '/export/{start}'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
      server.plugins['jade'].acton
    ]
    handler: ( request, reply ) ->
      server.app.cache.get 'allLeads', ( err, cached ) ->
        if cached is null
          reply(' go get new data' )
        else
          reply.redirect '/'
          setTimeout ->
            server.app.io.sockets.emit 'message',
              message: 'Exporting leads to acton starting with # ' + sliceStart
              type: 'success'
          , 500
          # console.log cached[0],
          _report = []
          sliceStart = parseInt( request.params.start )
          slice = Array.prototype.slice.call( cached, sliceStart )
          # slice = cached
          q = Async.queue upsertLead, 1
          q.drain = ->
            server.app.io.sockets.emit 'message',
              message: 'All leads exported' + sliceStart
              type: 'success'
              hideAfter: false
            return null
          Async.forEachOf( slice, ( lead, key, done ) ->
            leadData = {}
            leadData["Created On"] = lead.created_time
            leadData["Topic"] = 'Facebook'
            # console.log key, lead
            lead.field_data.forEach ( data ) ->
              if data.name is 'full_name'
                leadData["Name"] = data.values[0]
              if data.name is 'email'
                leadData["Email"] = data.values[0]
              return null
            console.log key + sliceStart, leadData
            task = {}
            task.leadData = leadData
            task.token = request.pre.act.access_token
            q.push task, ( err ) ->
              if err
                throw err
              console.log 'upsert ' + ( key + sliceStart ) + ' was Completed for ' + leadData.Email
              return null
            return null
          , ( err ) ->
            if err
              throw err
            return null
          )
        return null
    # getQuery = {
    #       sql: 'SELECT * FROM `users` WHERE ?',
    #       values: [
    #         sid: data.sid
    #       ]
    #     }
    #     server.plugins['mysql'].query getQuery, ( rows ) ->
    #       user = rows[0]

upsertLead = ( data, done ) ->
  opts =
    method: 'PUT'
    url: '/api/1/list/l-0086/record'
    baseUrl: 'https://restapi.actonsoftware.com'
    qs:
      email: data.leadData.Email
    json: data.leadData
  Request opts, ( err, resp, body ) ->
    console.log resp.statusCode, body
    server.app.io.sockets.emit 'message',
      message: resp.statusCode + ' ' + body.message + ' for ' + data.leadData.Email
      type: 'success'
    setTimeout ->
      done()
    , 3000
    return null
  .auth null, null, true, data.token

# getAllLeads = ( array, request, done ) ->
#   opts =
#     method: 'GET'
#     json: true
#     baseUrl: 'https://graph.facebook.com'
#     url: '/v2.5/' + request.params.formid + '/leads'
#     qs:
#       access_token: request.auth.credentials.facebook.access_token
#   getLeads array, opts, ( array ) ->
#     server.log [ 'lead count' ], array.length
#     done array
#     return null
#   return null
#
#
# getLeads = ( array, opts, done ) ->
#   Request opts, ( err, resp, body ) ->
#     if err
#       throw err
#     server.log [ 'lead page request', 'status' ], resp.statusCode
#     body.data.forEach ( object ) ->
#       array.push object
#       return null
#     if body.paging
#       if body.paging.next
#         opts.qs.after = body.paging.cursors.after
#         getLeads array, opts, done
#       else
#         done array
#     else
#       done body.data
#     return null
#   return null

# server.route
#   method: 'GET'
#   path: '/import/{formid}'
#   config:
#     pre: [
#       server.plugins['jade'].global
#     ]
#     handler: ( request, reply ) ->
#       opts =
#         method: 'GET'
#         json: true
#         baseUrl: 'https://www.facebook.com'
#         url: '/ads/leadgen/export_csv'
#         qs:
#           id: request.params.formid
#           type: 'form'
#       return Request opts, ( err, resp, body ) ->
#         console.log body
#         # request.pre.forms = body.data
#         return reply.view 'forms', request.pre

server.route
  method: 'GET'
  path: '/fb/{formid}/leads/{paging?}'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
    ]
    handler: ( request, reply ) ->
      opts =
        method: 'GET'
        json: true
        baseUrl: 'https://graph.facebook.com'
        url: '/v2.5/' + request.params.formid + '/leads'
        qs:
          access_token: request.auth.credentials.facebook.access_token
          limit: 25
      paging = request.session.get 'paging'
      if request.params.paging is 'next'
        opts.qs.after = paging.cursors.after
      if request.params.paging is 'prev'
        opts.qs.before = paging.cursors.before
      console.log opts.qs
      return Request opts, ( err, resp, body ) ->
        # console.log body
        request.pre.leads = body.data
        request.pre.paging = body.paging
        request.session.set 'paging', body.paging
        return reply.view 'leads', request.pre


# server.route
#   method: 'GET'
#   path: '/fb/leads/{formid}'
#   config:
#     pre: [
#       server.plugins['jade'].global
#     ]
#     handler: ( request, reply ) ->
#       opts =
#         method: 'GET'
#         json: true
#         baseUrl: 'https://graph.facebook.com'
#         url: '/v2.5/' + fbPageId + '/leadgen_forms'
#         qs:
#           access_token: request.session.get('facebook').access_token
#       return Request opts, ( err, resp, body ) ->
#         console.log body
#         request.pre.forms = body.data
#         return reply.view 'forms', request.pre

server.route
  method: 'GET'
  path: '/acton/lists'
  config:
    pre: [
      server.plugins['jade'].global
      server.plugins['jade'].acton
    ]
    handler: ( request, reply ) ->
      opts =
        url: '/api/1/list'
        baseUrl: 'https://restapi.actonsoftware.com'
        method: 'GET'
        json: true
      return Request opts, ( err, resp, body ) ->
        request.pre.lists = body
        return reply.view 'lists', request.pre
      .auth null, null, true, request.pre.act.access_token

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

# server.route
#   method: 'GET'
#   path: '/realtime'
#   config:
#     handler: ( request, reply ) ->
#       console.log request.query
#       if request.query.hub is undefined
#         return reply().code 404
#       if request.query.hub.mode is 'subscribe'
#         return reply request.query.hub.challenge
#       else
#         return reply().code 400


# server.route
#   method: 'POST'
#   path: '/realtime'
#   config:
#     payload:
#       output: 'data'
#     handler: ( request, reply ) ->
#       request.log [ 'ping', 'facebook', 'realtime' ], request.payload
#       console.log 'Recieved PING~'
#       console.log request.payload
#       console.log '~PING'
#       return reply()

server.start ->
  return console.info 'Server started at: ', server.info.uri
