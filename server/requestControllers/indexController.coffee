models = require '../../models'
config = require '../config.json'

landingPage = (res) ->
  res.render 'index.jade',
    title : 'Scrap'
    description: ''
    author: 'scrap'
    names: { 1: "" }
    current_collection:
      collectionKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    if !req?.session?.currentUserId
      return landingPage res

    userId = req.session.currentUserId
    options =
      where: { id: userId }
      include: [
        { model: models.Collection, include: [models.User] }
      ]

    models.User.find( options ).done (err, user) ->
      return callback err, res if err?
      return landingPage res unless user?

      user.Articles = []
      collections = {}
      for collection in user.Collections.reverse()
        key = collection.collectionKey
        collections[key] = collection.dataValues

      res.render 'main', { user, collections, host: config.HOST }
