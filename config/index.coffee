Confidence = require 'confidence'
Path = require 'path'

store = new Confidence.Store

  connection:
    $filter: 'env'
    production:
      host: 'localhost'
      port: 8013
    $default: # for devs
      host: 'localhost'
      port: 8013

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
      register: require '../plugins/sockets'
    ,
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
