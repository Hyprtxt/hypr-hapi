module.exports =
  title: 'NASM Connector'
  javascripts: [
    '/socket.io/socket.io.js'
    '/nginx/js/jquery/jquery.min.js'
    '/nginx/js/messenger/messenger.min.js'
    '/nginx/js/script.js'
  ]
  stylesheets: [
    '/nginx/css/messenger/messenger.css'
    '/nginx/css/messenger/messenger-theme-air.css'
    '/nginx/css/style.css'
  ]
  navbarBrand:
    title: 'NASM Connector'
    link: '/'
  navigation: [
    title: 'Readme'
    link: '/readme'
  ,
    title: 'FB Leadgen Forms'
    link: '/fb/leadgen_forms'
  ,
    title: 'Acton Lists'
    link: '/acton/lists'
  ]
  env: process.env.NODE_ENV
  # JSON.stringify( process.env, null, 2 )
  timestamp: new Date()
