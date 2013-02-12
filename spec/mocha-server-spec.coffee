MochaServer = require '../lib/mocha-server'
fs = require 'fs'
path = require 'path'
console.log __filename
downcaser = require './support/downcaseCompiler'

makeTempFileSync = (name) ->
  tmpDir = path.join(process.cwd(), 'tmp')
  fs.mkdirSync(tmpDir) unless fs.existsSync(tmpDir)

  filePath = path.join(tmpDir, name)
  unless fs.exists(filePath)
    fs.writeFileSync(filePath, "console.log 'woot woot'")
  filePath

describe 'Mocha Server', ->
  describe 'constructor', ->
    describe '#_setMochaCache', ->
      beforeEach ->
        @app = cache: { set: sinon.stub() }
        makeTempFileSync 'test.js'
        tmpDir = path.join process.cwd(), 'tmp'
        sinon.stub(path, 'dirname').returns tmpDir
        MochaServer::_setMochaCache 'test.js', @app

      it 'caches the file path for a given file', ->
        expect(@app.cache.set.lastCall.args).to.contain 'test.js'



  describe '#_setUpCompilers', ->
    beforeEach ->
      compilerPaths =
        downcaser: 'spec/support/downcaseCompiler'
        fooCaser: 'spec/support/downcaseCompiler'
      @Snockets = require('snockets')
      MochaServer::_setUpCompilers compilerPaths

    it 'attaches command line compilers to snockets', ->
      expect(@Snockets.compilers['downcaser']).to.equal(downcaser)
      expect(@Snockets.compilers['fooCaser']).to.equal(downcaser)

  describe '#loadCompiler', ->
    context 'given the loaded module returns an object with match and compileSync properties', ->
      beforeEach ->
        @compilerPath = './spec/support/downcaseCompiler'
        @expectedPath = path.join process.cwd(), @compilerPath
        @compiler = MochaServer::_loadCompiler @compilerPath

      it 'returns the object as the compiler', ->
        expect(@compiler).to.equal require(@expectedPath)

    context 'given the loaded module returns a class', ->
      beforeEach ->
        @compilerPath = './spec/support/uppercaseCompilerClass'
        @expectedPath = path.join process.cwd(), @compilerPath
        @compiler = MochaServer::_loadCompiler @compilerPath

      it 'returns an object of that class', ->
        expect(@compiler).to.be.an.instanceOf require(@expectedPath)

  describe '#_shouldInclude', ->
    context 'with no compiler set', ->
      beforeEach ->

      it 'should include js files', ->
        expect(MochaServer::._shouldInclude(makeTempFileSync 'test.js')).to.be.true

      it 'should not include dot files', ->
        expect(MochaServer::._shouldInclude(makeTempFileSync '.test.js')).to.be.false
        expect(MochaServer::._shouldInclude(makeTempFileSync '.test')).to.be.false

      it 'should include coffee files', ->
        expect(MochaServer::._shouldInclude(makeTempFileSync 'hugo.coffee')).to.be.true

      it 'should not include jade files', ->
        expect(MochaServer::._shouldInclude(makeTempFileSync 'hugo.jade')).to.be.false

    context 'with external compiler set', ->
      beforeEach ->
        MochaServer::compilers = downcase: 'spec/support/downcaseCompiler'

      it 'should include files matching the compiler\'s extension', ->
        expect(MochaServer::._shouldInclude(makeTempFileSync 'hugo.downcase')).to.be.true

