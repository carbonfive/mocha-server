{ exec } = require 'child_process'

task 'test', 'Run all unit tests', ->
  reporter = process.env.MOCHA_REPORTER || null
  reporterOpt = if reporter then "-R #{reporter}" else ""
  specOpts = "--compilers coffee:coffee-script -r ./spec/test-helper.js --recursive -t 10000 --colors --headless --ignore-leaks"
  exec "NODE_ENV=test mocha --compilers coffee:coffee-script spec/ #{reporterOpt} #{specOpts} ", (error, stdout) ->
    console.log stdout
    throw error if error

