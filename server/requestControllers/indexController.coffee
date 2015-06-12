models = require '../../models'
indexElements = require '../indexElements'

indexPage = (res) ->
  res.render 'index.jade',
    title : 'Welcome to Scrap!'
    description: ''
    author: 'scrap'
    colors: {}
    names: { 1: "" }
    elements: indexElements
    current_space:
      spaceKey: 'index'
    

module.exports =
  index: (req, res, callback) ->
    if req.session.currentUserId?
      currentUserId = req.session.currentUserId
      models.User.find(
        where: { id: currentUserId }
        include: [ models.Space ]
      ).complete (err, user) ->
        return callback err if err?
        return indexPage res unless user?
        req.session.currentUserId = user.id
        user.spaces.reverse()
        res.render 'meta-space.jade', { user, title:'' }
        callback()
    else
      indexPage res
      callback()