models = require '../../models'
indexCollections = require '../indexCollections'

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
  index: (req, res, callback) ->
    if req.session.currentUserId?
      currentUserId = req.session.currentUserId
      models.User.find(
        where: { id: currentUserId }
        include: [ {model:models.Space, include:[model:models.Element]} ]
      ).complete (err, user) ->
        return callback err if err?
        return indexPage res unless user?
        req.session.currentUserId = user.id        
        
        for space in user.spaces
          space.elements.reverse()

        console.log JSON.stringify(user.space)
        res.render 'home.jade', {user, title: 'title'}
        callback()
    else
      indexPage res
      callback()