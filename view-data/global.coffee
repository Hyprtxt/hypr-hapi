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
    title: 'Checkout Mockup'
    link: '/'
  navigation: [
    title: 'Readme'
    link: '/readme'
  ,
    title: ' 1-800-460-6276'
    class: [ 'fa', 'fa-phone', 'text-bold' ]
    link: 'tel:1-800-460-6276'
    liclass: [ 'pull-right', 'btn', 'btn-info' ]
  ]
  timestamp: new Date()
  env: process.env.NODE_ENV
