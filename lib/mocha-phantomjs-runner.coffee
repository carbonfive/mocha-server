fs = require 'fs'
exists = fs.existsSync || path.existsSync
spawn = require('child_process').spawn
path = require 'path'

launch = ({ reporter }) ->
  spawnArgs = []
  if reporter
    spawnArgs.push '-R'
    spawnArgs.push reporter
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
