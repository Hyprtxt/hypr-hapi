module.exports =
  title: 'AFAA'
  javascripts: [
    '/js/jquery/jquery.min.js'
    '/js/bootstrap/util.js'
    '/js/bootstrap/collapse.js'
    '/js/script.js'
  ]
  stylesheets: [
    '/css/font-awesome/font-awesome.min.css'
    '/css/style.css'
  ]
  navbarBrand:
    title: 'AFAA'
    link: '/'
  navigation: [
    title: 'Readme'
    link: '/readme'
  ,
    title: 'Become A Trainer'
    link: '#'
  ,
    title: 'Courses'
    link: '#'
  ,
    title: 'Resources'
    link: '#'
  ,
    title: 'Events'
    link: '#'
  ,
    title: 'Contact'
    link: '#'
  ,
    title: 'Blog'
    link: '#'
  ,
    title: 'Login'
    link: '#'
    liclass: 'pull-right'
  ]
  timestamp: new Date()
  env: process.env.NODE_ENV
