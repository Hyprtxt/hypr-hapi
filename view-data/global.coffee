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
    class: [
      'btn'
      'btn-sm'
      'btn-success-outline'
    ]
  ,
    title: 'Message History'
    link: '/history'
    class: [
      'btn'
      'btn-sm'
      'btn-warning-outline'
    ]
  ,
    title: 'Acton Lists'
    link: '/acton/lists'
    class: [
      'btn'
      'btn-sm'
      'btn-primary-outline'
    ]
  ,
    title: 'Halt Export'
    id: 'halt'
    class: [
      'btn'
      'btn-sm'
      'btn-danger-outline'
    ]
  ,
    title: 'Logout'
    link: '/logout'
    class: [
      'btn'
      'btn-sm'
      'btn-secondary-outline'
    ]
  #   title: 'FB Leadgen Forms'
  #   link: '/fb/leadgen_forms'
  # ,
  ]
  env: process.env.NODE_ENV
  # JSON.stringify( process.env, null, 2 )
  timestamp: new Date()
