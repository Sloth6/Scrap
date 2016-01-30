sio = require('socket.io')
models = require '../models'

collectionController = require './socketControllers/collectionController'
articleController = require './socketControllers/articleController'
articleCollectionController = require './socketControllers/articleCollectionController'

errorHandler = require './errorHandler'
validator = require 'validator'

clean = (data) ->
  # for k, v of data
  #   data[k] = (validator.escape v)#.replace /\n/g, '<br>'
  data

module.exports = (io)->
  io.sockets.on 'connection', (socket) ->
    userId = socket.handshake.session.currentUserId
    
    return unless userId?

    socket.handshake.session.userId = userId
    
    models.User.find(
      where: { id: userId }
      include: [ { model: models.Collection }]
    ).then (user) ->
      return unless user?
      socket.handshake.session.user = user
      socket.join "user:#{userId}"
      for collection in user.Collections
        socket.join collection.collectionKey

      console.log "user #{userId} joined #{user.Collections.length} collections"

      socket.on 'newArticle',   (data) -> articleController.newArticle io, socket, clean(data), errorHandler
      socket.on 'deleteArticle', (data) -> articleController.deleteArticle io, socket, clean(data), errorHandler
      socket.on 'updateArticle', (data) -> articleController.updateArticle io, socket, data, errorHandler
      
      socket.on 'addArticleCollection', (data) -> articleCollectionController.addToCollection io, socket, clean(data), errorHandler
      socket.on 'removeArticleCollection', (data) -> articleCollectionController.removeFromCollection io, socket, clean(data), errorHandler
      
      collectionEvents = [
        'reorderCollection', 'addCollection',
        'removeCollection', 'inviteToCollection'
      ]
      for eventName in collectionEvents
        socket.on eventName, (data) ->
          collectionController[eventName] io, socket, clean(data), errorHandler
      # socket.on , (data) -> collectionController.reorderArticles io, socket, clean(data), errorHandler
      # socket.on 'addCollection', (data) -> collectionController.newCollection io, socket, clean(data), errorHandler
      # socket.on 'removeCollection', (data) -> collectionController.deleteCollection io, socket, clean(data), errorHandler
      # socket.on 'inviteToCollection', (data) -> collectionController.inviteToCollection io, socket, clean(data), errorHandler
      
      socket.on 'disconnect', ->
        console.log 'Client Disconnected.'
