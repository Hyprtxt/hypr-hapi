module.exports =
  title: 'Hyprtxt Static'
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
    title: 'Hyprtxt Static'
    link: '/'
  navigation: [
    title: 'Readme'
    link: '/readme.html'
  ,
    title: 'Add Beer'
    link: '/add.html'
  ]
  env: process.env.NODE_ENV
  # JSON.stringify( process.env, null, 2 )
  timestamp: new Date()
