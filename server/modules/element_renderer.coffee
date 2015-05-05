jade = require 'jade'
fs = require 'fs'

module.exports = (space, {content, contenType}, cb) ->
  colors = () ->
    map = {}
    n_colors = 10
    for i in [0...space.users.length]
      id = space.users[i].id
      map[id] = i%n_colors
    map

  names = () ->
    map = {}
    for user in space.users
      map[user.id] = user.name
    map

  file = __dirname + "/../../views/partials/element.jade"
  fs.readFile file, 'utf8', (err, data) ->
    return cb(err) if err 
    fn = jade.compile data
    html = fn {element:{content, contenType}, colors:colors(), name:names()}
    cn null, html

# module.exports('foo', 'text')