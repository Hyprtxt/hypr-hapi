module.exports =
  title: 'NASM Connector'
  javascripts: [
    '/nginx/js/jquery/jquery.min.js'
    '/nginx/js/script.js'
  ]
  stylesheets: [
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
    link: '/facebook/leadgen_forms'
  ,
    title: 'Acton Lists'
    link: '/acton/lists'
  ]
  env: process.env.NODE_ENV
  # JSON.stringify( process.env, null, 2 )
  timestamp: new Date()
