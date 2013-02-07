module.exports = {
  match: /\.js$/,
  compileSync: function(sourcePath, source) {
    return source.toLowerCase();
  }
};