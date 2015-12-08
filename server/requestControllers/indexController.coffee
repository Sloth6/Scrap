models = require '../../models'

indexPage = (res) ->
  res.render 'index.jade',
    title : 'Scrap'
    description: ''
    author: 'scrap'
    names: { 1: "" }
    current_collection:
      collectionKey: 'index'


formatCollection = (collection) ->
  articles = collection.Articles or []
  children = collection.children or []

  collection.content = articles.concat children
  articleOrder       = collection.articleOrder      
        
  collection.content.sort (a, b) -> 
    if a instanceof models.Collection.Instance
      a_i = articleOrder.indexOf(a.collectionKey)
    else
      a_i = articleOrder.indexOf("#{a.id}")

    if b instanceof models.Collection.Instance
      b_i = articleOrder.indexOf(b.collectionKey)
    else
      b_i = articleOrder.indexOf("#{b.id}")

    if a_i > b_i then 1 else -1

  collection

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
          return res.send(400) unless collection?

          collection.children = user.Collections or []
          formatCollection(collection)
          res.render 'home.jade', { user, collection, title: 'Scrap' }
    else
      indexPage res
      callback null