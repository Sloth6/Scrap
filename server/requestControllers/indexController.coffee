models = require '../../models'
indexCollections = require '../indexCollections'
collection = require '../modelControllers/collection'

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
      models.User.find( where: { id: req.session.currentUserId }).complete (err, user) ->
        return callback err if err?
        return indexPage res unless user?
        models.Space.find({
          where: { root:true, UserId: user.id }
          include:[ models.User ] #model:models.Element, 
        }).complete (err, collection) ->
          return callback err if err?
          res.render 'home.jade', { user, collection, title: 'Hotpot' }
          callback()
    else
      indexPage res
      callback()