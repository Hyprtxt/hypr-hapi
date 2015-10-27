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
  path: '/nasm'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
      server.plugins['jade'].facebook
    ]
    handler: ( request, reply ) ->
      opts =
        method: 'GET'
        json: true
        baseUrl: 'https://graph.facebook.com'
        url: '/v2.5/' + fbPageId + '/leadgen_forms'
        qs:
          access_token: request.auth.credentials.facebook.access_token
      console.log request.auth.credentials.facebook.access_token + ' CREDSSSS'
      Request opts, ( err, resp, body ) ->
        console.log body
        request.pre.forms = body.data
        reply.view 'forms', request.pre
        return null
      return null

server.route
  method: 'GET'
  path: '/readme'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
      server.plugins['jade'].facebook
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
      server.plugins['jade'].facebook
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

server.route
  method: 'GET'
  path: '/logout'
  config:
    handler: ( request, reply ) ->
      request.session.reset()
      return reply.redirect '/'

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

# Async Queue Setup

server.route
  method: 'GET'
  path: '/history'
  config:
    auth: 'facebook'
    pre: [
      server.plugins['jade'].global
    ]
    handler: ( request, reply ) ->
      server.app.cache.get 'messageCache', ( err, cached ) ->
        if cached is null
          cached = []
        request.pre.messages = cached
        reply.view 'history', request.pre
        return null
      return null

upsertLead = ( data, done ) ->
  opts =
    method: 'POST'
    url: 'http://certify.nasm.org/acton/eform/14843/0009/d-ext-0002'
    qs: data.leadData
  startTime = Date.now()
  Request opts, ( err, resp, body ) ->
    console.log resp.statusCode, body
    theMessage = '#' + data.number + ' ' + data.leadData.Email + ' code: ' + resp.statusCode
    server.app.cache.get 'messageCache', ( err, cached ) ->
      if cached is null
        cached = []
      else
        cached.push theMessage
      server.app.cache.set 'messageCache', cached, 0, ->
        server.app.io.sockets.emit 'message',
          message: theMessage
          type: 'success'
        return null
      return null
    latency = Date.now() - startTime
    wait = ( 500 - latency )
    if wait > 0
      timeout = wait
    else
      timeout = 0
    console.log latency, wait
    setTimeout ->
      done()
    , timeout
    return null
  .auth null, null, true, data.token

server.app.q = Async.queue upsertLead, 10

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
          server.app.q.drain = ->
            server.app.io.sockets.emit 'message',
              message: 'All leads exported' + sliceStart
              type: 'success'
              hideAfter: false
            return null
          Async.forEachOf( slice, ( lead, key, done ) ->
            leadData = {}
            leadData["utm_source"] = 'facebook'
            leadData["utm_medium"] = 'display'
            leadData["utm_campaign"] = 'FB Lead Ads'
            # leadData["_CAMPAIGN"] = 'facebook'
            leadData["Topic"] = 'facebook'
            leadData["_TIME"] = lead.created_time
            # console.log key, lead
            lead.field_data.forEach ( data ) ->
              if data.name is 'full_name'
                uHname = data.values[0].split(' ')
                leadData["FirstName"] = uHname.shift()
                leadData["LastName"] = uHname.join(' ')
              if data.name is 'email'
                leadData["Email"] = data.values[0]
              return null
            console.log key + sliceStart, leadData
            task = {}
            task.leadData = leadData
            task.token = request.pre.act.access_token
            task.number = ( key + sliceStart )
            server.app.q.push task, ( err ) ->
              if err
                throw err
              console.log 'upsert ' + ( key + sliceStart ) + ' requested for ' + leadData.email
              return null
            return null
          , ( err ) ->
            if err
              throw err
            return null
          )
        return null
      return null

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
      Request opts, ( err, resp, body ) ->
        # console.log body
        request.pre.leads = body.data
        request.pre.paging = body.paging
        request.session.set 'paging', body.paging
        return reply.view 'leads', request.pre
      return null

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

server.start ->
  return console.info 'Server started at: ', server.info.uri
