# Hyprtxt Hapi

Cool stuff!

* Software freedom
* The terminal is your friend
* CoffeeScript everywhere
* Whitespace is king
* Automate all the things
* Source control, `git`

# Quick Start

1. Clone the repo: `git clone https://github.com/Hyprtxt/gulp.git`
1. Get in there: `cd gulp`
1. Make sure you have bower and gulp: `npm i -g bower gulp`
1. Install dependencies: `npm i;bower install`
1. Fire it up: `npm start`

You will now need a webserver to serve up the `static_generated` directory. The site uses absoulte links (starting with '/'). This means loading the index.html page with file://~ in your browser will not work. The site will fail to find external stylesheets files and scripts.

## Starting from nothing

* Node installed with NVM
* [Atom](https://atom.io/) - Text Editor
* [Nginx](https://www.nginx.com/) - Web Server
* [Chrome](https://www.google.com/chrome/) - Browser
* Chrome with [LiveReload Extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en)
* iTerm2 - But any terminal will do

# Hyprtxt Gulp

#### Install `node_modules` and `bower_components`

`npm install; bower install`

#### Fire it up!

`npm start` or `gulp` or `gulp watch` - they all do the same thing

That will create the `static_generated` directory, where you final web site lives.

### Install Nginx

OSX: `brew install nginx`
Ubuntu: `apt-get update; apt-get install nginx`

You want to serve up the `static_generated` directory, use your hosts file to create a domain like gulp.hyprtxt.dev for local development. Below is an example configuration

```
server {
  server_name gulp.hyprtxt.dev;
  root /Users/taylor/www/gulp.hyprtxt.com/static_generated;
  location / {
    try_files $uri.html $uri $uri/ =404;
    index index.html;
    autoindex on;
  }
}
```

The try files line is important, it allows you to visit your generated .html pages without including the extension.

# Front End

## Configuration

`./view-data/global.coffee` is passed to all Jade templates. Use it for global front-end configuration values.

## Node Package Manager

Well, you're here after all, so I'd guess you already know why `npm` is so great. What follows is a an explanation of the major packages in use by Hyprtxt.

## Bower

Bower is used to manage OP's (other peoples) client side code.

* jQuery
* Bootstrap
* Font Awesome

## Gulp

[Gulp](http://gulpjs.com/) is a task runner that enables awesome like:

* Automated moving of the things (copies files for us, enables Bower)
* SASS (Source Mapping, AutoPrefixing)
* CoffeeScript (Source Mapping)
* LiveReload (Via Chrome Extension)

files in the `./src` directory are compiled and output to the `./static_generated` directory
