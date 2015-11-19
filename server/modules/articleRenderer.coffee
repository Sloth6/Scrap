path = __dirname+'/../../views/partials/article.jade'
jadeFun = require('jade').compileFile path, {  filename: path }

module.exports = (collection, element) ->
  nameMap = () ->
    map = {}
    for user in collection.users
      map[user.id] = user.name
    map

  collection.nameMap = nameMap collection.users
  return encodeURIComponent jadeFun({ element, collection })