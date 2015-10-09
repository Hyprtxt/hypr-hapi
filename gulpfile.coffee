gulp = require 'gulp'
gutil = require 'gulp-util'
sass = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'
autoprefixer = require 'gulp-autoprefixer'
coffee = require 'gulp-coffee'
livereload = require 'gulp-livereload'
rimraf = require 'rimraf'
list = require 'gulp-task-listing'
exec = require('child_process').exec

dest = './static_generated'

gulp.task 'default', [ 'watch' ]

gulp.task 'help', list

gulp.task 'clean', ( cb ) ->
  return rimraf dest, cb

gulp.task 'sass', ->
  return gulp.src './src/sass/**/*.sass'
    .pipe sourcemaps.init()
    .pipe sass(
        outputStyle: 'expanded'
        includePaths: [ './bower_components/' ]
      ).on 'error', sass.logError
    .pipe autoprefixer ['> 1%']
    .pipe sourcemaps.write '../map' # , sourceRoot: __dirname + './src'
    .pipe gulp.dest dest + '/css'
    .pipe livereload()

gulp.task 'copyjs', ->
  gulp.src './bower_components/bootstrap/js/dist/*'
    .pipe gulp.dest dest + '/js/bootstrap'
  gulp.src './bower_components/underscore/**.js'
    .pipe gulp.dest dest + '/js/underscore'
  gulp.src './bower_components/backbone/**.js'
    .pipe gulp.dest dest + '/js/backbone'
  return gulp.src './bower_components/jquery/dist/*'
    .pipe gulp.dest dest + '/js/jquery'

gulp.task 'copymap', ->
  gulp.src './bower_components/underscore/**.map'
    .pipe gulp.dest dest + '/js/underscore'
  return gulp.src './bower_components/backbone/**.map'
    .pipe gulp.dest dest + '/js/backbone'

gulp.task 'copycss', ->
  return

gulp.task 'copyfont', ->
  return gulp.src './bower_components/font-awesome/fonts/*'
    .pipe gulp.dest dest + '/fonts'

gulp.task 'coffee', ->
  return gulp.src './src/coffee/**/*.coffee'
    .pipe sourcemaps.init()
    .pipe coffee(
        bare: true
      ).on 'error', gutil.log
    .pipe sourcemaps.write '../map' # , sourceRoot: __dirname + './src'
    .pipe gulp.dest dest + '/js'
    .pipe livereload()

gulp.task 'reload', ->
  return livereload.reload()

gulp.task 'watch', [ 'copyfont', 'copycss', 'sass', 'copymap', 'copyjs', 'coffee' ], ->
  gulp.watch './static/**/*.*', ['reload']
  gulp.watch './src/sass/**/*.sass', ['sass']
  gulp.watch './src/coffee/**/*.coffee', ['coffee']
  gulp.watch './views/**/*.jade', ['jade']
  gulp.watch './view-data/**/*.coffee', ['jade']
  gulp.watch './readme.md', ['jade']
  return livereload.listen
    basePath: './src'
    start: true

# static site stuff
jade = require 'gulp-jade'
fs = require 'fs'
coffeeScript = require 'coffee-script'

jadeData = {}
gulp.task 'setupJadeData', ( next ) ->
  fs.readFile './view-data/global.coffee', 'utf8', ( err, _data ) ->
    if err
      throw err
    else
      coffeeopts =
        bare: true
        header: false
      jadeData = eval coffeeScript.compile _data, coffeeopts
    return next()

gulp.task 'jade', [ 'setupJadeData' ], ->
  return gulp.src [ './views/**/*.jade', '!./views/layout/**' ]
    .pipe jade
      locals: jadeData
      pretty: true
    .pipe gulp.dest dest
    .pipe livereload()

gulp.task 'copystatic', ->
  return gulp.src [ './static/**', dest + '/**' ]
    .pipe gulp.dest dest

gulp.task 'render', [ 'copystatic', 'jade', 'copyfont', 'copycss', 'sass', 'copyjs', 'coffee' ], ( cb ) ->
  return rimraf dest + '/map', cb

gulp.task 'build', [ 'clean' ], ->
  return gulp.start 'render'
