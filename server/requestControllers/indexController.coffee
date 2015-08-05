models = require '../../models'
indexCollections = require '../indexCollections'

nameMap = (users) ->
  map = {}
  for {name, id, email} in users
    # split = name.split(' ')
    # first = split[0]
    # last = if split.length > 1 then split[1] else ''
    map[id] = {name, email}
  map

indexPage = (res) ->
  res.render 'index.jade',
    title : 'Hotpot · Keep Everything for Your Project in One Place'
    description: ''
    author: 'scrap'
    names: { 1: "" }
    collections: indexCollections
    current_space:
      spaceKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    if req.session.currentUserId?
      currentUserId = req.session.currentUserId
      models.User.find(
        where: { id: currentUserId }
        include: [ {model:models.Space, include:[model:models.Element, models.User]} ]
      ).complete (err, user) ->
        return callback err if err?
        return indexPage res unless user?
        req.session.currentUserId = user.id        
        
        for space in user.spaces
          space.nameMap = nameMap space.users
          # console.log space.nameMap

          space.elements.sort (a, b) ->
            return 1 if a.createdAt < a.createdAt
            return -1 if a.createdAt > b.createdAt
            return 0

        res.render 'home.jade', { user, title: 'Hotpot' }
        callback()
    else
      indexPage res
      callback()