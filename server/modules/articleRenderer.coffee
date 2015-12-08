path = __dirname+'/../../views/partials/article.jade'
jadeFun = require('jade').compileFile path, {  filename: path }

module.exports = (collection, article) ->
  nameMap = () ->
    map = {}
    for user in collection.Users
      map[user.id] = user.name
    map

  collection.nameMap = nameMap collection.Users
  return encodeURIComponent jadeFun({ article, collection })