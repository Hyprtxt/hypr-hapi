Confidence = require 'confidence'
Path = require 'path'
#
Grant = require('grant').hapi()
grant = new Grant()

store = new Confidence.Store

  connection:
    $filter: 'env'
    production:
      host: 'localhost'
      port: 8006
    $default: # for devs
      host: 'nasm.dev'
      port: 8008

  view:
    $filter: 'env'
    $base:
      engines:
        jade: require 'jade'
      path: Path.join( __dirname , '../views' )
    production:
      compileOptions:
        pretty: false
      isCached: true
    $default:
      compileOptions:
        pretty: true
      isCached: false

  plugin: [
    # static file serving
      register: require 'inert'
    ,
    # view serving
      register: require 'vision'
    ,
    # cookie jar
      register: require 'yar'
      options:
        cookieOptions:
          password: 'ChangeMePlz'
          isSecure: false
    ,
    # grant, Oauth2 for Act-On API
      register: grant.register
      options:
        server:
          protocol: 'http'
          host: 'nasm.dev'
          callback: '/callback'
          transport: 'session'
          state: true
        acton:
          # # NASM
          # key: '70wyAs_4Vn057gAcGodAOXnLYNQa'
          # secret: 't7ThrJQapiUsVgdslbfqPoQuKIUa'
          # Hyprtxt
          key: 'Drqi8At9LgrlHQUP4S6a6rEJrDIa'
          secret: '_TifPts48nGDvcqZgXvQ6cY63Swa'
          scope: [ 'PRODUCTION' ]
          callback: 'http://nasm.dev/acton/callback'
          redirect_uri: 'http://nasm.dev/acton/callback'
    ,
    # # jade helper
    #   register: require '../plugins/jade'
    # ,
    # event logging
      register: require 'good'
      options:
        opsInterval: 1000
        reporters:[
          reporter: require 'good-console'
          events:
            log: '*'
            response: '*'
        ,
          reporter: require 'good-file'
          events:
            log: '*'
            response: '*'
          config: Path.join( __dirname, '../log', 'good.log' )
        ]
  ]

criteria =
  # https://docs.npmjs.com/misc/config#production
  env: process.env.NODE_ENV

exports.get = ( key ) ->
  return store.get key, criteria
