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
      models.User.find( where: { id: req.session.currentUserId }).complete (err, user) ->
        return callback err if err?
        return indexPage res unless user?
        models.Collection.find({
          where: { root: true, UserId: user.id }
          include:[ 
            model: models.User
            model: models.Collection, as: 'children'
          ]
        }).complete (err, collection) ->
          return callback err if err?
          return callback 'no collection found' unless collection?
          res.render 'home.jade', { user, collection, title: 'Scrap' }
          callback null
    else
      indexPage res
      callback null