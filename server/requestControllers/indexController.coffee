models = require '../../models'
indexElements = require '../indexElements'

indexPage = (res) ->
  res.render 'index.jade',
    title : 'Welcome to Scrap!'
    description: ''
    author: 'scrap'
    elements: indexElements
    current_space:
      spaceKey: 'index'
    analyticssiteid: 'XXXXXXX'

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
        
        # res.redirect "/s/" + user.spaces[0].spaceKey
        res.render 'meta-space.jade',
          user: user
          title: user.name
        callback()
    else
      indexPage res
      callback()
