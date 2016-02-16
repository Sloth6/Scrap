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
    if !req?.session?.currentUserId
      return indexPage res
    
    userId = req.session.currentUserId
    options = 
      where: { id: userId }
      include: [
        { model: models.Collection }
        { model: models.Article, order: '"createdAt" DESC', include: [{ model:models.Collection, required: false }] }
      ]

    models.User.find( options ).done (err, user) ->
      return callback err, res if err?
      return indexPage res unless user?
      
      user.Articles.length = 100
      collections = {}
      for collection in user.Collections 
        key = collection.collectionKey
        collections[key] = collection.dataValues

      console.log "Showing #{user.Articles.length} articles"
      res.render 'main', { user, collections }
