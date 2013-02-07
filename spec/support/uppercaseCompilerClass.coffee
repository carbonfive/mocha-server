module.exports = class UppercaseCompiler

  match: /\.js$/,
  compileSync: (sourcePath, source) ->
    source.toUpperCase()
