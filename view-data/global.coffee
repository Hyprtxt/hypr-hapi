module.exports =
  title: 'Hypr-Hapi'
  javascripts: [
    '/socket.io/socket.io.js'
    '/nginx/js/jquery/jquery.min.js'
    '/nginx/js/script.js'
  ]
  stylesheets: [
    '/nginx/css/style.css'
  ]
  navbarBrand:
    title: 'Hyprtxt GPIO'
    link: '/'
  navigation: [
    title: 'A Link'
    link: '#somewhere'
  ]
  timestamp: new Date()
  env: process.env.NODE_ENV
