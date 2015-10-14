Confidence = require 'confidence'
Path = require 'path'
#
Grant = require('grant').hapi()
grant = new Grant()

store = new Confidence.Store

  server:
    cache:
      name: 'redis'
      engine: require 'catbox-redis'
      host: 'pub-redis-16865.us-east-1-4.6.ec2.redislabs.com'
      port: 16865
      password: '7DB.syK7JXktkUbrK[fm'

  connection:
    $filter: 'env'
    production:
      host: 'localhost'
      port: 8006
    $default: # for devs
      host: 'acton.nasm.dev'
      port: 8006

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
    # jade helper
      register: require '../plugins/jade'
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
          host: 'acton.nasm.dev'
          callback: '/callback'
          transport: 'session'
          state: true
        acton:
          # Technically Secrets, but this is a private repo
          # # NASM
          # key: '70wyAs_4Vn057gAcGodAOXnLYNQa'
          # secret: 't7ThrJQapiUsVgdslbfqPoQuKIUa'
          # Hyprtxt
          key: 'Drqi8At9LgrlHQUP4S6a6rEJrDIa'
          secret: '_TifPts48nGDvcqZgXvQ6cY63Swa'
          scope: [ 'PRODUCTION' ]
          callback: '/acton/callback'
          # redirect_uri: 'http://nasm.dev/acton/callback'
        facebook:
          key: '1513710378927269'
          secret: 'b7741bad6244c28f34d6bdc2e9116def'
          # https://developers.facebook.com/docs/facebook-login/permissions/v2.5
          # scope: [ 'ads_management' ]
          scope: [ 'public_profile', 'ads_read', 'manage_pages', 'user_website', 'user_status' ]
          callback: '/facebook/callback'
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
          config: Path.join( __dirname, '../logs', 'good.log' )
        ]
  ]

criteria =
  # https://docs.npmjs.com/misc/config#production
  env: process.env.NODE_ENV

exports.get = ( key ) ->
  return store.get key, criteria
