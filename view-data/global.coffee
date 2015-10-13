module.exports =
  title: 'NASM Connector'
  javascripts: [
    '/js/jquery/jquery.min.js'
    '/js/underscore/underscore-min.js'
    '/js/backbone/backbone-min.js'
    '/js/script.js'
  ]
  stylesheets: [
    '/css/style.css'
  ]
  navbarBrand:
    title: 'NASM Connector'
    link: '/'
  navigation: [
    title: 'Readme'
    link: '/readme'
  ]
  env: process.env.NODE_ENV
  # JSON.stringify( process.env, null, 2 )
  timestamp: new Date()
