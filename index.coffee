Hapi = require 'hapi'

server = new Hapi.Server()

server.connection require('./config').get '/connection'

server.register require('./config').get('/plugin'), ( err ) ->
  if err
    throw err
  return

server.views require('./config').get '/view'

do ->
  childProcess = require('child_process')
  oldSpawn = childProcess.spawn
  mySpawn = ->
    console.log 'spawn called'
    console.log arguments
    result = oldSpawn.apply(this, arguments)
    result
  childProcess.spawn = mySpawn
  return



# Homepage
server.route
  method: 'GET'
  path: '/'
  config:
    pre: [ server.plugins['jade'].global ]
    handler: ( request, reply ) ->
      terminal = require('child_process').spawn('bash')
      terminal.stdout.on 'data', ( data ) ->
        console.log 'stdout: \n' + data
        return
      terminal.on 'exit', ( code ) ->
        console.log 'child process exited with code ' + code
        reply.view 'index', request.pre
        return

      console.log 'Sending stdin to terminal'
      terminal.stdin.write 'echo "Hello $USER."\n'
      terminal.stdin.write 'ls\n'
      terminal.stdin.write 'gulp build\n'
      # terminal.stdin.write 'cd ~/www\n'
      # terminal.stdin.write './ls.sh\n'
      console.log 'Ending terminal session'
      terminal.stdin.end()
      return

      # deploySh = spawn('ls', ['--help'], cwd: '~/www/').on 'error', ( err ) ->
      #   throw err
      # # deploySh.stdout.on 'data', ( data ) ->
      # #   console.log 'stdout: ' + data


spawn = require('child_process').spawn
server.route
  method: 'POST'
  path: '/'
  config:
    handler: ( request, reply ) ->
      console.log process.env.PATH
      deploySh = spawn 'sh', [ 'ls.sh' ], cwd: '~/'
      deploySh.stdout.on 'data', (data) ->
        console.log 'stdout: ' + data
      console.log request.payload.repository.name
      reply 'success'


server.start ->
  return console.log 'Server running at:', server.info.uri
