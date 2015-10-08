# Hyprtxt Static

I can make the things with this, you too!

* Freedom of software
* The terminal is your friend
* Whitespace is king
* Automate all the things
* Source control, `git`
* `s/ftp` is something to be avoided

## Get Started

You'll need

* Node installed with NVM
* [Atom](https://atom.io/) - Text Editor
* [Nginx](https://www.nginx.com/) - Web Server
* [Chrome](https://www.google.com/chrome/) - Browser
  * The [LiveReload Extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en) for Chrome
* iTerm2 - A Terminal

#### Install Bower and Gulp globally

`npm i -g bower gulp`

#### Install `node_modules` and `bower_components`

`npm install;bower install`

#### Fire it up!

`npm start` in Terminal #1
`gulp watch` in Terminal #2

### Install NVM

`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.28.0/install.sh | bash`

### Install Nginx

@todo For OSX and Ubuntu?

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

Okay this one is technically a Ruby module. Used for CSS.

### Coffee Script

Coffee Script is at the very heart of this project.

### Jade

The HTML template language
