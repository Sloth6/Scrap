models = require '../../models'

nameMap = (users) ->
  map = {}
  for {name, id, email} in users
    # split = name.split(' ')
    # first = split[0]
    # last = if split.length > 1 then split[1] else ''
    map[id] = {name, email}
  map

readOnlyPage = (res) ->
  res.render 'read-only.jade',
    title : 'Hotpot · Here is a read-only space'
    description: ''
    author: 'scrap'
    names: { 1: "" }
    current_space:
      spaceKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    if req.session.currentUserId?
      currentUserId = req.session.currentUserId
      models.User.find(
        where: { id: currentUserId }
        include: [ {
          model:models.Space, include:[ model:models.Element, models.User ]
        } ]
      ).complete (err, user) ->
        return callback err if err?
        return readOnlyPage res unless user?
        req.session.currentUserId = user.id        
        
        for space in user.spaces
          space.nameMap = nameMap space.users
          space.elements.sort (a, b) ->
            new Date(b.createdAt) - new Date(a.createdAt)

        res.render 'home.jade', { user, title: 'Hotpot' }
        callback()
    else
      readOnlyPage res
      callback()