nameMap = (users) ->
  map = {}
  for {name, id, email} in users
    # split = name.split(' ')
    # first = split[0]
    # last = if split.length > 1 then split[1] else ''
    map[id] = {name, email}
  map


module.exports = 
	load : ({root, collectionKey}) ->
		models.Collection.find({
      where: { root, collectionKey }
      include:[ model:models.Article, models.User ]
    }).complete (err, collection) ->
      return callback err if err?