fs = require 'fs'
exists = fs.existsSync || path.existsSync
spawn = require('child_process').spawn
path = require 'path'

copyPropertyToArg = (property, flag, args) ->
  if property?
    args.push "-#{flag}"
    args.push property

copyMapToArg = (map, flag, args) ->
  if map?
    for key, value in map
      args.push "-#{flag}"
      args.push "#{key}=#{value}"

launch = ({
  reporter, cookies, headers,
  settings, viewport, agent
  }) ->

  spawnArgs = []
  copyPropertyToArg(reporter, 'R', spawnArgs)
  copyPropertyToArg(agent, 'A', spawnArgs)
  copyMapToArg(cookies, 'c', spawnArgs)
  copyMapToArg(headers, 'h', spawnArgs)
  copyMapToArg(settings, 's', spawnArgs)
  if viewport?
    spawnArgs.push '--view'
    spawnArgs.push "#{viewport.width}x#{viewport.height}"
  spawnArgs.push 'http://localhost:8888'

  for i in [0..module.paths.length]
    bin = path.join module.paths[i], '.bin/mocha-phantomjs'
    if exists bin
      mochaPhantomjs = spawn bin, spawnArgs
      break

  if mochaPhantomjs == undefined
    mochaPhantomjs = spawn 'mocha-phantomjs', spawnArgs

  mochaPhantomjs.stdout.pipe process.stdout,  end: false
  mochaPhantomjs.stderr.pipe process.stderr,  end: false
  mochaPhantomjs.on 'exit', (code) ->
    process.exit code

module.exports = exports = { launch }
