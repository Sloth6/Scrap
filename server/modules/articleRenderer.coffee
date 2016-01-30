path = __dirname+'/../../views/partials/article.jade'
jadeFun = require('jade').compileFile path, {  filename: path }

module.exports = (article, collections) ->
  return jadeFun({ article, collections })