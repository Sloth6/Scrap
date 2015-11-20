async = require 'async'
models = require '../models'
mail = require './adapters/nodemailer'
articleRenderer = require './modules/articleRenderer.coffee'
newCollection = require './newCollection'

module.exports = (user, collectionKey, callback) ->
  coverAttributes =
    CollectionId: null
    creatorId: null
    contentType: 'cover'
    content: collectionKey

  models.Collection.find({
    where: { collectionKey }
    include:[ model:models.User]
  }).complete (err, collection) ->
    return callback(err) if err?
    return callback('no collection found for '+collectionKey) unless collection?
    return callback('cant add user to root collection') if collection.root
    coverAttributes.CollectionId = collection.id
    coverAttributes.creatorId = user.id
    async.waterfall [
      (cb) ->
        collection.hasUser(user).complete (err, hasUser) ->
          if hasUser then cb('repeat add user to a collection') else cb(null)

      (cb) ->
        collection.addUser(user).complete cb

      (user, cb) -> # get the root collection
        models.Collection.find({ where: { root:true, UserId: user.id } }).complete cb
      
      # Create cover article
      (rootCollection, cb) ->
        return cb('no root collection found for invitee') unless rootCollection?
        coverAttributes.CollectionId = rootCollection.id
        models.Article.create(coverAttributes).complete (err, cover) ->
          if err then cb err else cb null, cover, rootCollection

      # Change article order
      (cover, rootCollection, cb) ->
        rootCollection.articleOrder.unshift(cover.id)
        rootCollection.save().complete (err) ->
          return cb(err) if err?
          cb null, cover, rootCollection

      (cover, rootCollection, cb) ->
        html = articleRenderer collection, cover
        cb null, html, collection
    ], callback