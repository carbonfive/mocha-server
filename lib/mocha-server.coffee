express = require 'express'
connectFileCache = require 'connect-file-cache'
fs = require 'fs'
path = require 'path'
resolve = path.resolve
exists = fs.existsSync || path.existsSync
join = path.join
basename = path.basename
cwd = process.cwd()
Snockets = require 'snockets'

class MochaServer
  constructor: ->
    @bail = false
    @ignoreLeaks = false
    @globals = null

    @app = express()
    @cache = connectFileCache()
    @app.use @cache.middleware
    @app.set "view engine", "jade"
    @app.set 'views', "#{__dirname}/../views"

    mochaDir = path.dirname require.resolve('mocha')
    cssPath = resolve mochaDir, 'mocha.css'
    css = fs.readFileSync cssPath
    jsPath = resolve mochaDir, 'mocha.js'
    js = fs.readFileSync jsPath
    @cache.set 'mocha.css', css
    @cache.set 'mocha.js', js

    @app.get "/", @show

  show: (request, response)=>
    files = []

    for path in @requirePaths.concat(@testPaths)
      for discoveredFilePath in @discoverFiles(path)
        resolvedFilePath = resolve discoveredFilePath
        files.push resolvedFilePath unless resolvedFilePath in files

    snockets = new Snockets
    scriptOrder = []
    for file in files
      for { filename, js } in snockets.getCompiledChain(file, async: false) when filename not in scriptOrder
        scriptOrder.push filename
        @cache.set filename, js

    response.render 'index', { scriptOrder , @ui, @bail, @ignoreLeaks }

  discoverFiles: (path)->
    re = /.(js|coffee)$/
    originalPath = path

    path = "#{originalPath}.js" unless exists path
    path = "#{originalPath}.coffee" unless exists path
    stat = fs.statSync path
    (return [path]) if stat.isFile()

    files = []
    for file in fs.readdirSync path
      do (file)=>
        file = join path, file
        stat = fs.statSync file
        if stat.isDirectory()
          files = files.concat(@discoverFiles file) if @recursive
          return
        return if !stat.isFile() or !re.test(file) or basename(file)[0] == '.'
        files.push file
    files

  run: (callback)->
    callback ?= -> console.log 'Tests available at http://localhost:8888'
    @app.listen 8888, callback

module.exports = exports = MochaServer
