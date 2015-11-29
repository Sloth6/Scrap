models = require '../../models'

indexPage = (res) ->
  res.render 'index.jade',
    title : 'Scrap'
    description: ''
    author: 'scrap'
    names: { 1: "" }
    current_collection:
      collectionKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    if req.session.currentUserId?
      userId = req.session.currentUserId
      options =
        where: { id: userId }
        include: [{
          required: false
          model: models.Collection
          where: { hasCover: true }
          include: [ models.User ]
        }]
      models.User.find( options ).done (err, user) ->
        return callback err, res if err?
        return indexPage res unless user?
        options = {where: { CreatorId: userId, root:true }}
        models.Collection.find(options).done (err, collection) ->    
          return callback err, res if err?
          collection.children = user.Collections or []
          return res.send(400) unless collection?
          res.render 'home.jade', { user, collection, title: 'Scrap' }
    else
      indexPage res
      callback null