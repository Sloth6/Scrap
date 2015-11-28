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

      models.User.find( options ).then (user) ->
        return indexPage res unless user?
        models.Collection.find({where: { CreatorId: userId, root:true }}).then (collection) ->    
          collection.children = user.Collections or []
          console.log collection.children
          return res.send(400) unless collection?
          res.render 'home.jade', { user, collection, title: 'Scrap' }
        # models.Collection.find({
        #   where: { root: true, UserId: user.id }
        #   include:[
        #     { model: models.Article }
        #     { model: models.User }
        #     { model: models.Collection, as: 'children', include: [models.User] }
        #   ]
        # }).then ( rootCollection) ->
        #   return callback 'no collection found' unless rootCollection?
          # models.Collection.find({
          #   where: { root: true, UserId: user.id }
          #   include:[
          #     { model: models.Article }
          #     { model: models.User }
          #     { model: models.Collection, as: 'children', include: [models.User] }
          #   ]
          # }).then ( collections) ->
          # res.render 'home.jade', { user, collection: rootCollection, title: 'Scrap' }
          # callback null
    else
      indexPage res
      callback null