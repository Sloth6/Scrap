path = __dirname+'/../../views/partials/collection.jade'
jadeFun = require('jade').compileFile path, {  filename: path }

module.exports = (collection) ->
  return encodeURIComponent jadeFun({ collection })