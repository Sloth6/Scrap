models = require '../../models'
newArticle = require '../newArticle'

module.exports =
  bookmarklet: (req, res, app, callback) ->
    userId = req.session.currentUserId
    url = req.query.referrer

    if !userId
      return res.redirect('/')

    if !url
      res.status(400).send 'invalid referrer param'

    options = 
      where: { id: userId }
      include: [
        { model: models.Collection }
      ]

    models.User.find( options ).done (err, user) ->
      return callback err, res if err?
      return res.redirect('/') unless user?

      newArticle url, user, (err, article) ->

        console.log "website added from an extension!"
        console.log "\t#{url}"

        return callback(err,res) if err?

        collections = {}
        for collection in user.Collections 
          key = collection.collectionKey
          collections[key] = collection.dataValues

        articleId = article.id
        res.render 'partials/bookmarkletContent', { url, collections, articleId }


  addArticleCollection: (req, res, app, callback) ->
    userId = req.session.currentUserId
    { articleId, collectionKey } = req?.body

    console.log 'addArticleCollection', { articleId, collectionKey, userId }

    models.Collection.find(where: { collectionKey }).done (err, collection) ->
      return callback(err, res) if err?
      models.Article.find(where: { id: articleId }).done (err, article) ->
        return callback(err, res) if err?
        article.addCollection(collection).done (err) ->
          return callback(err, res) if err?
          collection.addArticle(article).done (err) ->
            return callback(err, res) if err?
            res.send(200)
