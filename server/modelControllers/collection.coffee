nameMap = (users) ->
  map = {}
  for {name, id, email} in users
    # split = name.split(' ')
    # first = split[0]
    # last = if split.length > 1 then split[1] else ''
    map[id] = {name, email}
  map


module.exports = 
	load : ({root, spaceKey}) ->
		models.Space.find({
      where: { root, spaceKey }
      include:[ model:models.Element, models.User ]
    }).complete (err, space) ->
      return callback err if err?