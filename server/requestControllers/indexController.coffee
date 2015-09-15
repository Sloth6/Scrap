models = require '../../models'

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
    title : 'Scrap · Keep Everything for Your Project in One Place'
    description: ''
    author: 'scrap'
    names: { 1: "" }
    current_space:
      spaceKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    if req.session.currentUserId?
      models.User.find( where: { id: req.session.currentUserId }).complete (err, user) ->
        return callback err if err?
        return indexPage res unless user?
        models.Space.find({
          where: { root: true, UserId: user.id }
          include:[ model:models.Element, models.User ]
        }).complete (err, space) ->
          return callback err if err?
          res.render 'home.jade', { user, collection:space, title: 'Scrap' }
          callback()
    else
      indexPage res
      callback()