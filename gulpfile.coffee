gulp = require('gulp')
gutil = require('gulp-util')
sass = require('gulp-sass')
sourcemaps = require('gulp-sourcemaps')
autoprefixer = require('gulp-autoprefixer')
coffee = require('gulp-coffee')
livereload = require('gulp-livereload')
rimraf = require('rimraf')
taskListing = require('gulp-task-listing')

gulp.task 'default', taskListing

gulp.task 'help', taskListing

gulp.task 'clean', ( cb ) ->
  rimraf './static_generated', cb
  return

gulp.task 'sass', ->
  gulp.src './src/sass/**/*.sass'
    .pipe sourcemaps.init()
    .pipe sass(
        outputStyle: 'expanded'
        includePaths: ['./bower_components/bootstrap/scss']
      ).on 'error', sass.logError
    .pipe autoprefixer ['> 1%']
    .pipe sourcemaps.write '../map' # , sourceRoot: __dirname + './src'
    .pipe gulp.dest './static_generated/css'
    .pipe livereload()
  return

gulp.task 'copyjs', ->
  gulp.src './bower_components/jquery/dist/*'
    .pipe gulp.dest './static_generated/js'

gulp.task 'copystyle', ->
  gulp.src './bower_components/font-awesome/css/*'
    .pipe gulp.dest './static_generated/css'

gulp.task 'coffee', ->
  gulp.src './src/coffee/**/*.coffee'
    .pipe sourcemaps.init()
    .pipe coffee(
        bare: true
      ).on 'error', gutil.log
    .pipe sourcemaps.write '../map' # , sourceRoot: __dirname + './src'
    .pipe gulp.dest './static_generated/js'
    .pipe livereload()
  return

gulp.task 'reload', ->
  # This task only works when the livereload server is up
  # Jade is compiled by Hapi, so a reload is all we need
  livereload.reload()
  return

gulp.task 'watch', ['copystyle', 'sass', 'copyjs', 'coffee'], ->
  livereload.listen
    basePath: './src'
    start: true
  gulp.watch './src/sass/**/*.sass', ['sass']
  gulp.watch './src/coffee/**/*.coffee', ['coffee']
  gulp.watch './views/**/*.jade', ['reload']
  return

# static site stuff
jade = require 'gulp-jade'
fs = require 'fs'
coffeeScript = require 'coffee-script'

_jadeData = {}
_pretty = true
gulp.task 'setupJadeData', ( next ) ->
  fs.readFile './view-data/global.coffee', 'utf8', ( err, _data ) ->
    if err
      throw err
    else
      coffeeopts =
        bare: true
        header: false
      _jadeData = eval coffeeScript.compile _data, coffeeopts
    return next()

gulp.task 'jade', [ 'setupJadeData' ], ->
  return gulp.src [ './views/**/*.jade', '!./views/layout/**' ]
    .pipe jade
      locals: _jadeData
      pretty: _pretty
    .pipe gulp.dest dest
    .pipe livereload()

gulp.task 'copystatic', ->
  return gulp.src [ './static/**', dest + '/**' ]
    .pipe gulp.dest dest

gulp.task 'render', [
    'copystatic'
    'jade'
    'copyfont'
    'copycss'
    'sass'
    'copyjs'
    'coffee'
  ], ( cb ) ->
  return rimraf dest + '/map', cb

gulp.task 'build', [ 'clean' ], ->
  return gulp.start 'render'
