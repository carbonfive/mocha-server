MochaServer = require '../lib/mocha-server'
fs = require 'fs'
path = require 'path'
console.log __filename
downcaser = require './support/downcaseCompiler'

describe 'Mocha Server', ->
  subject = null

  describe '#setUpCompilers', ->
    beforeEach ->
      @compilers =
        downcaser: 'spec/support/downcaseCompiler'
        fooCaser: 'spec/support/downcaseCompiler'
      subject = new MochaServer({ compilers: @compilers })
      @Snockets = require('snockets')

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

    makeTempFileSync = (name) ->
      tmpDir = path.join(process.cwd(), 'tmp')
      fs.mkdirSync(tmpDir) unless fs.existsSync(tmpDir)

      filePath = path.join(tmpDir, name)
      unless fs.exists(filePath)
        fs.writeFileSync(filePath, "console.log 'woot woot'")
      filePath


    context 'with no compiler set', ->
      beforeEach ->
        subject = new MochaServer({})

      it 'should include js files', ->
        expect(subject._shouldInclude(makeTempFileSync 'test.js')).to.be.true

      it 'should not include dot files', ->
        expect(subject._shouldInclude(makeTempFileSync '.test.js')).to.be.false
        expect(subject._shouldInclude(makeTempFileSync '.test')).to.be.false

      it 'should include coffee files', ->
        expect(subject._shouldInclude(makeTempFileSync 'hugo.coffee')).to.be.true

      it 'should not include jade files', ->
        expect(subject._shouldInclude(makeTempFileSync 'hugo.jade')).to.be.false

    context 'with external compiler set', ->
      beforeEach ->
        subject = new MochaServer({compilers: {downcase: 'spec/support/downcaseCompiler'}})
      it 'should include files matching the compiler\'s extension', ->
        expect(subject._shouldInclude(makeTempFileSync 'hugo.downcase')).to.be.true

