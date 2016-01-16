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
      models.User.find( where: { id: userId } ).done (err, user) ->
        return callback err, res if err?
        return indexPage res unless user?
        models.Article.findAll({
          where: { creatorId: userId }
          include: [ 
            { model: models.User, as: 'Creator' }
            { model: models.Collection } 
          ]
        }).done (err, articles) ->
          return callback err if err?
          options = {where: { CreatorId: userId, root:true }}
          models.Collection.find(options).done (err, rootCollection) ->
            return callback err if err?

            collections = {}
            
            for article in articles
              # if !(article.Collection.collectionKey in collections)
              key = article.Collection.collectionKey
              collections[key] = article.Collection.dataValues
            # console.log collections
            console.log "Showing #{articles.length} articles"
            res.render 'prototype', { articles, rootCollection, collections, user }
    else
      indexPage res
      callback null