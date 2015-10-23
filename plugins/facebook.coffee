Request = require 'request'

exports.register = ( server, options, next ) ->

  cache = server.cache
    expiresIn: 10 * 60 * 1000

  server.app.cache = cache

  _page = 1

  getAllLeads = ( array, request, done ) ->
    _page = 1
    opts =
      method: 'GET'
      json: true
      baseUrl: 'https://graph.facebook.com'
      url: '/v2.5/' + request.params.formid + '/leads'
      qs:
        access_token: request.auth.credentials.facebook.access_token
    getLeads array, opts, ( array ) ->
      server.log [ 'lead count' ], array.length
      server.app.io.sockets.emit 'message',
        message: 'Loaded ' + array.length + ' leads from Facebook API'
        type: 'success'
      done array
      return null
    return null

  getLeads = ( array, opts, done ) ->
    Request opts, ( err, resp, body ) ->
      if err
        throw err
      server.app.io.sockets.emit 'message',
        message: 'Loaded lead page ' + _page + ' from Facebook API'
        type: 'success'
      server.log [ 'lead page request', 'status' ], resp.statusCode
      body.data.forEach ( object ) ->
        array.push object
        return null
      if body.paging
        if body.paging.next
          _page++
          opts.qs.after = body.paging.cursors.after
          getLeads array, opts, done
        else
          done array
      else
        done body.data
      return null
    return null

  server.expose 'getAllLeads', ( request, reply ) ->
    cache.get 'allLeads', ( err, cached ) ->
      if err
        throw err
      if !cached
        getAllLeads [], request, ( data ) ->
          cache.set 'allLeads', data, 0, ->
          request.pre.leads = data
          reply()
          return null
      else
        server.app.io.sockets.emit 'message',
          message: 'Loaded leads from cache'
          type: 'success'
        request.pre.leads = cached
        reply()
      return null
    return null

  return next()

exports.register.attributes =
  name: 'facebook'
  version: '0.1.0'
