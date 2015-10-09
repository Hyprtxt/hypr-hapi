# Beer Test

@todo, prune package.json


### Deps

```
npm i
npm i -g gulp bower nodemon coffee-script
bower install
```


### Make it go
```
nodemon proxy.coffee
gulp
```

### Nginx Configuration

```
server {
  listen 80;
  server_name gulp.hyprtxt.dev;
  root /var/www/gulp.hyprtxt.com/static_generated;
  location / {
    index index.html;
    autoindex on;
  }
  location /api {
    proxy_pass http://gulp.hyprtxt.dev:8080;
    include global/proxy.conf;
  }
}
```

### Hosts File

```
127.0.0.1 gulp.hyprtxt.dev
```

# Hyprtxt Static

I can make the things with this, you too! It's pretty neat stuff; Real fast cause it's async and parallel.

Hyprtxt static is built on the following principles:

* Software Freedom
* The terminal is your friend
* JavaScript (but... Coffee!)
* Whitespace is king
* Automate all the things
* Source control, `git`
* `s/ftp` is something to be avoided

## Get Started

You'll need some things!

* Node installed with NVM
* [Atom](https://atom.io/) - Text Editor
* [Nginx](https://www.nginx.com/) - Web Server
* [Chrome](https://www.google.com/chrome/) - Browser
  * The [LiveReload Extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en) for Chrome
* iTerm2 - A Terminal

### Install NVM

`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.28.0/install.sh | bash`

#### Install Bower and Gulp globally

`npm i -g bower gulp`

#### Install `node_modules` and `bower_components`

`npm install;bower install`

#### Fire it up!

`gulp watch`

That will create the `static_generated` directory, where you final web site lives.

### Install Nginx

@todo For OSX and Ubuntu?

You want to serve up the `static_generated` directory, use your hosts file to create a domain like gulp.hyprtxt.dev for local development.

# Front End

## Configuration

`./view-data/global.coffee` is passed to all Jade templates. Use it for global front-end configuration values.

# Node Package Manager

Well, you're here after all, so I'd guess you already know why `npm` is so great. What follows is a an explanation of the major packages in use by Hyprtxt.

# Bower

Bower is used to manage OP's (other peoples) client side code.

* jQuery
* Bootstrap
* Font Awesome

## Gulp

[Gulp](http://gulpjs.com/) is a task runner that enables awesome like:

* Automated moving of the things (copies files for us, enables Bower)
* SASS (Source Mapping, AutoPrefixing)
* CoffeeScript (Source Mapping)
* Jade (HAPI or Static)
* LiveReload (Via Chrome Extension)
* Static website building

Files in the `./src` directory are compiled and output to the `./static_generated` directory

### SASS

Okay this one is technically a Ruby module. Used for CSS. Stylus is better, but Font Awesome and Bootstrap are written in SASS...

### Coffee Script

Coffee Script is at the very heart of this project.

### Jade

Preferred HTML template language.
