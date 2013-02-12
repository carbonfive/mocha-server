express = require 'express'
connectFileCache = require 'connect-file-cache'
fs = require 'fs'
path = require 'path'
exists = fs.existsSync
Snockets = require 'snockets'
mochaPhantomJSRunner = require('./mocha-phantomjs-runner')

class MochaServer
  constructor: (options) ->
    @_configureOptions(options)
    @_setUpCompilers(@compilers)
    @_clearGlobals()

    @_setUpServer()
    @_setMochaCache 'mocha.js',  @app
    @_setMochaCache 'mocha.css', @app

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

  show: (request, response, next) =>
    files = @_discoverFilesInPaths @requirePaths.concat(@testPaths)

    snockets = new Snockets
    scriptOrder = []
    for file in files
      for { filename, js } in snockets.getCompiledChain(file, async: false) when filename not in scriptOrder
        scriptOrder.push filename
        @app.cache.set filename, js
    response.render 'index', { scriptOrder , @ui, @bail, @ignoreLeaks }

  _configureOptions: (options) ->
    @requirePaths = options['requirePaths']
    @testPaths = options['testPaths']
    @recursive = options['recursive']
    @ui = options['ui']
    @bai = options['bai']
    @ignoreLeaks = options['ignoreLeaks']
    @headless = options['headless']
    @reporter = options['reporter']
    @compiler = options['compiler']
    @cookies = options['cookies']
    @headers = options['headers']
    @settings = options['settings']
    @viewport = options['viewport']
    @age = options['age']

    # Defaults
    @bail ?= false
    @ignoreLeaks ?= false
    @compilers ?= {}

  _clearGlobals: -> @globals = null

  _setUpServer: ->
    @app = express()
    @app.cache = connectFileCache()
    @app.use @app.cache.middleware
    @app.set "view engine", "jade"
    @app.set 'views', "#{__dirname}/../views"

    @app.get "/", @show
    @app.use (error, request, response, next) =>
      console.error error.stack
      response.status(500).render 'error', { error }
      process.exit(1) if @headless

  _setMochaCache: (filename, app) ->
    mochaDir = path.dirname require.resolve('mocha')
    filePath = path.resolve mochaDir, filename
    file = fs.readFileSync filePath
    app.cache.set filename, file

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

  _setUpCompilers: (compilerPaths)->
    for ext, compilerPath of compilerPaths
      Snockets.compilers[ext] = @_loadCompiler compilerPath

  _loadCompiler: (compilerPath) ->
    compiler = require path.join process.cwd(), compilerPath
    if compiler instanceof Function
      new compiler
    else
      compiler

  _fileMatchingRegExp: (compilers) ->
    s = '^[^\.].*\.(js|coffee'
    for ext of compilers
      s += '|' + ext
    s += ')$'
    new RegExp(s)

  _shouldInclude: (file)->
    @re = @_fileMatchingRegExp(@compilers)
    @re.test(path.basename(file))

  _run: (callback)->
    callback ?= -> console.log 'Tests available at http://localhost:8888'
    @app.listen 8888, callback

module.exports = exports = MochaServer
