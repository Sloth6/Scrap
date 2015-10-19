element_jade = null
require('fs').readFile __dirname+'/../../views/partials/element.jade', 'utf8', (err, data) ->
  throw err if err
  element_jade = require('jade').compile data


module.exports = (collection, element) ->
  colors = () ->
    map = {}
    n_colors = 10
    for i in [0...collection.users.length]
      id = collection.users[i].id
      map[id] = i%n_colors
    map

  nameMap = () ->
    map = {}
    for user in collection.users
      map[user.id] = user.name
    map

  collection.nameMap = nameMap collection.users

  html = encodeURIComponent(element_jade({ element, collection }))
  return html