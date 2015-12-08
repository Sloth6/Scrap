sio = require('socket.io')
url = require('url')
collectionController = require './socketControllers/collectionController'
articleController = require './socketControllers/articleController'

errorHandler = require './errorHandler'
validator = require 'validator'
models = require '../models'

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
      for collection in user.Collections
        socket.join collection.collectionKey

      console.log "user #{userId} joined #{user.Collections.length} collections"

      socket.on 'newArticle',   (data) -> articleController.newArticle io, socket, clean(data), errorHandler
      socket.on 'deleteArticle', (data) -> articleController.deleteArticle io, socket, clean(data), errorHandler
      socket.on 'updateArticle', (data) -> articleController.updateArticle io, socket, data, errorHandler
      socket.on 'renameCover', (data) -> collectionController.rename io, socket, data, errorHandler
      socket.on 'moveToCollection', (data) -> articleController.moveToCollection io, socket, clean(data), errorHandler
      socket.on 'reorderArticles', (data) -> collectionController.reorderArticles io, socket, clean(data), errorHandler
      socket.on 'newStack', (data) -> collectionController.newStack io, socket, clean(data), errorHandler
      socket.on 'newPack', (data) -> collectionController.newPack io, socket, clean(data), errorHandler
      socket.on 'deleteCollection', (data) -> collectionController.deleteCollection io, socket, clean(data), errorHandler
      socket.on 'inviteToCollection', (data) -> collectionController.inviteToCollection io, socket, clean(data), errorHandler
      
      socket.on 'disconnect', ->
        console.log 'Client Disconnected.'
