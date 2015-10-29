module.exports =
  title: 'Hyprtxt Static'
  javascripts: [
    '/js/jquery/jquery.min.js'
    '/js/script.js'
  ]
  stylesheets: [
    '/css/font-awesome/font-awesome.min.css'
    '/css/style.css'
  ]
  navbarBrand:
    title: 'Hyprtxt Static'
    link: '/'
  navigation: [
    title: 'Test Page'
    link: '/test'
  ,
    title: 'Another Link'
    link: '#somewhere'
  ]
  timestamp: new Date()
  env: process.env.NODE_ENV
