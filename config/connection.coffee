Confidence = require('confidence')
Path = require('path')

store = new Confidence.Store
  connectionConfig:
    $filter: 'env'
    production:
      host: 'localhost'
      port: 8003
    $default: # for devs
      host: 'videopoker.dev'
      port: 8003

criteria =
  # https://docs.npmjs.com/misc/config#production
  env: process.env.NODE_ENV

exports.get = ( key ) ->
  return store.get key, criteria
