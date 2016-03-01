models = require '../../models'

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
        { model: models.Collection }
        # { model: models.Article, order: '"createdAt" ASC', include: [{ model:models.Collection, required: false }] }
      ]

    models.User.find( options ).done (err, user) ->
      return callback err, res if err?
      return landingPage res unless user?

      # user.Articles.reverse()
      # user.Articles.length = 0
      user.Articles = []
      collections = {}
      for collection in user.Collections.reverse()
        key = collection.collectionKey
        collections[key] = collection.dataValues

      res.render 'main', { user, collections }
