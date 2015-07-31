models = require '../../models'
indexCollections = require '../indexCollections'

nameMap = (users) ->
  map = {}
  for {name, id, email} in users
    map[id] = {name, email}
  map

indexPage = (res) ->
  res.render 'index.jade',
    title : 'Hotpot: Collect & Share Anything Instantly'
    description: ''
    author: 'scrap'
    colors: {}
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
          space.userMap = nameMap space.users
          # console.log space.userMap
          space.elements.sort (a, b) ->
            return 1 if a.createdAt < a.createdAt
            return -1 if a.createdAt > b.createdAt
            return 0
          # if space.elements.length
          #   console.log space.elements.map (e) -> e.id

        res.render 'home.jade', { user, title: 'title' }
        callback()
    else
      indexPage res
      callback()