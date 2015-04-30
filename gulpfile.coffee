del = require 'del'
gulp = require 'gulp'
less = require 'gulp-less'
shell = require 'gulp-shell'
order = require 'gulp-order'
coffee = require 'gulp-coffee'
filter = require 'gulp-filter'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
bowerFiles = require 'main-bower-files'
runSequence = require 'run-sequence'

gulp.task 'install:bower', ->
  shell.task 'bower install'

gulp.task 'clean', ->
  del 'public/*'

gulp.task 'vendor:styles', ->
  gulp.src bowerFiles()
  .pipe filter '*.css'
  .pipe concat 'vendor.css'
  .pipe minifyCss()
  .pipe gulp.dest 'public/vendor'

gulp.task 'vendor:scripts', ->
  gulp.src bowerFiles()
  .pipe filter '*.js'
  .pipe order ['jquery.js', 'underscore.js', '*']
  .pipe concat 'vendor.js'
  .pipe uglify()
  .pipe gulp.dest 'public/vendor'

gulp.task 'vendor:fonts', ->
  gulp.src bowerFiles()
  .pipe filter ['*.eot', '*.svg', '*.ttf', '*.woff']
  .pipe gulp.dest 'public/fonts'

gulp.task 'build:vendor', ->
  runSequence [
    'install:bower'
    'clean'
  ], [
    'vendor:styles'
    'vendor:scripts'
    'vendor:fonts'
  ]

gulp.task 'build:styles', ->
  gulp.src 'core/public/style/*.less'
  .pipe less()
  .pipe concat 'core.css'
  .pipe minifyCss()
  .pipe gulp.dest 'public'

gulp.task 'build:scripts', ->
  gulp.src 'core/public/script/*.coffee'
  .pipe coffee()
  .pipe order ['root.coffee', '*']
  .pipe concat 'core.js'
  .pipe uglify()
  .pipe gulp.dest 'public'

gulp.task 'build', ['build:vendor', 'build:styles', 'build:scripts']
