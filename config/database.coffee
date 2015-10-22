Confidence = require 'confidence'

store = new Confidence.Store

  mysql:
    $filter: 'env'
    production:
      connectionLimit: 100
      host: 'localhost'
      user: 'root'
      password: ''
      database: 'nasm_facebook'
      debug: false
    $default: # for devs
      connectionLimit: 10
      host: 'localhost'
      user: 'root'
      password: ''
      database: 'nasm_facebook'
      debug: false

criteria =
  # https://docs.npmjs.com/misc/config#production
  env: process.env.NODE_ENV

exports.get = ( key ) ->
  return store.get key, criteria
