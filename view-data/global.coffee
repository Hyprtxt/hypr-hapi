module.exports =
  title: 'Hyprtxt Static'
  javascripts: [
    '/js/jquery.min.js'
    '/js/script.js'
  ]
  stylesheets: [
    '/css/style.css'
  ]
  navbarBrand:
    title: 'Hyprtxt Static'
    link: '/'
  navigation: [
    title: 'A Link'
    link: '/test'
  ,
    title: 'Another Link'
    link: '#somewhere'
  ]
  timestamp: new Date()
  env: process.env.NODE_ENV
