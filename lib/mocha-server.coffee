express = require 'express'
connectFileCache = require 'connect-file-cache'
fs = require 'fs'
path = require 'path'
exists = fs.existsSync || path.existsSync
Snockets = require 'snockets'
mochaPhantomJSRunner = require('./mocha-phantomjs-runner')

class MochaServer
  constructor: ({
    @requirePaths, @testPaths, @recursive, @ui, @bail,
    @ignoreLeaks, @headless, @reporter, @compilers,
    @cookies, @headers, @settings, @viewport, @agent
    }) ->

    @bail ?= false
    @ignoreLeaks ?= false
    @compilers ?= {}

    @_setUpCompilers(@compilers)

    @globals = null

    @app = express()
    @cache = connectFileCache()
    @app.use @cache.middleware
    @app.set "view engine", "jade"
    @app.set 'views', "#{__dirname}/../views"

    mochaDir = path.dirname require.resolve('mocha')
    cssPath = path.resolve mochaDir, 'mocha.css'
    css = fs.readFileSync cssPath
    jsPath = path.resolve mochaDir, 'mocha.js'
    js = fs.readFileSync jsPath
    @cache.set 'mocha.css', css
    @cache.set 'mocha.js', js

    @app.get "/", @show

  launch: ->
    if @headless
      @_run =>
        mochaPhantomJSOptions = {
          @reporter, @cookies, @headers,
          @settings, @viewport, @agent
        }
        mochaPhantomJSRunner.launch mochaPhantomJSOptions
    else
      @_run()

  show: (request, response)=>
    files = @_discoverFilesInPaths @requirePaths.concat(@testPaths)

    snockets = new Snockets
    scriptOrder = []
    for file in files
      for { filename, js } in snockets.getCompiledChain(file, async: false) when filename not in scriptOrder
        scriptOrder.push filename
        @cache.set filename, js

    response.render 'index', { scriptOrder , @ui, @bail, @ignoreLeaks }

  _discoverFilesInPaths: (paths)->
    files = []
    for p in paths
      for discoveredFilePath in @_discoverFiles(p)
        resolvedFilePath = path.resolve discoveredFilePath
        files.push resolvedFilePath unless resolvedFilePath in files
    files

  _discoverFiles: (rootPath)->
    originalPath = rootPath

    rootPath = "#{originalPath}.js" unless exists rootPath
    rootPath = "#{originalPath}.coffee" unless exists rootPath
    stat = fs.statSync rootPath
    (return [rootPath]) if stat.isFile()

    files = []
    for file in fs.readdirSync rootPath
      do (file)=>
        file = path.join rootPath, file
        stat = fs.statSync file
        if stat.isDirectory()
          files = files.concat(@_discoverFiles file) if @recursive
          return
        return if not stat.isFile() or not @_shouldInclude(file)
        files.push file
    files

  _setUpCompilers: (compilers)->
    for ext, compiler of compilers
      Snockets.compilers[ext] = require path.join process.cwd(), compiler

  _fileMatchingRegExp: ->
    s = '^[^\.].*\.(js|coffee'
    for ext of @compilers
      s += '|' + ext
    s += ')$'
    new RegExp(s)

  _shouldInclude: (file)->
    @re ||= @_fileMatchingRegExp()
    @re.test(path.basename(file))

  _run: (callback)->
    callback ?= -> console.log 'Tests available at http://localhost:8888'
    @app.listen 8888, callback

module.exports = exports = MochaServer
