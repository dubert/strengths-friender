'use strict'

var gulp = require('gulp')
var http = require('http')
var st = require('st')
var exec = require('child_process').exec
var gutil = require('gulp-util')
var ftp = require('vinyl-ftp')
var clear = require('clear')
var counter = 0
var cred = require('./stuff/credentials.js')

var cmd = 'elm make ./src/Main.elm --output ./dist/bundle.js'
var cmdDev = cmd + ' --debug'

clear()

// MAIN tasks

gulp.task('default', ['server', 'watch-dev', 'elm-dev'])

gulp.task('prod', ['server', 'watch', 'elm'])

// TODO: make sequential with 'elm'
gulp.task('deploy', ['ftp'])

// HELPER tasks

gulp.task('watch', function(cb) {
  gulp.watch('**/*.elm', ['elm'])
})

gulp.task('watch-dev', function(cb) {
  gulp.watch('**/*.elm', ['elm-dev'])
})

gulp.task('server', function(done) {

  gutil.log(gutil.colors.blue('Starting server at http://localhost:4000'))

  http.createServer(st({
    path: __dirname + '/dist/',
    index: 'index.html',
    cache: false
  })).listen(4000, done)

})

gulp.task('elm', function(cb) {

  if (counter > 0) clear()

  exec(cmd, function(err, stdout, stderr) {
    if (err){
      gutil.log(gutil.colors.red('elm make: '),gutil.colors.red(stderr))
    } else {
      gutil.log(gutil.colors.green('elm make: '), gutil.colors.green(stdout))
    }
    cb()
  })

  counter++
})

gulp.task('elm-dev', function(cb) {

  if (counter > 0) clear()

  exec(cmdDev, function(err, stdout, stderr) {
    if (err){
      gutil.log(gutil.colors.red('elm make: '), gutil.colors.red(stderr))
    } else {
      gutil.log(gutil.colors.green('elm make: '), gutil.colors.green(stdout))
    }
    cb()
  })

  counter++
})

gulp.task('ftp', function() {

  var conn = ftp.create({
    host: cred.host,
    user: cred.user,
    password: cred.pass,
    log: gutil.log
  })

  var globs = [
    'dist/**'
  ]

  return gulp.src( globs, { base: 'dist', buffer: false } )
    .pipe( conn.newer('/') )
    .pipe( conn.dest('/') )
})
