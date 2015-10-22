Request = require 'request'

getAllLeads = ( array, request, done ) ->
  opts =
    method: 'GET'
    json: true
    baseUrl: 'https://graph.facebook.com'
    url: '/v2.5/' + request.params.formid + '/leads'
    qs:
      access_token: request.auth.credentials.facebook.access_token
  getLeads array, opts, ( array ) ->
    console.log [ 'lead count' ], array.length
    done array
    return null
  return null

getLeads = ( array, opts, done ) ->
  Request opts, ( err, resp, body ) ->
    if err
      throw err
    console.log [ 'lead page request', 'status' ], resp.statusCode
    body.data.forEach ( object ) ->
      array.push object
      return null
    if body.paging
      if body.paging.next
        opts.qs.after = body.paging.cursors.after
        getLeads array, opts, done
      else
        done array
    else
      done body.data
    return null
  return null

exports.register = ( server, options, next ) ->

  cache = server.cache
    expiresIn: 10 * 60 * 1000

  server.app.cache = cache

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
        request.pre.leads = cached
        reply()
      return null
    return null

  return next()

exports.register.attributes =
  name: 'facebook'
  version: '0.1.0'
