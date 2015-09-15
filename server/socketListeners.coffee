sio = require('socket.io')
url = require('url')
spaceController = require './socketControllers/spaceController'
elementController = require './socketControllers/elementController'
errorHandler = require './errorHandler'
validator = require 'validator'
models = require '../models'
clean = (data) ->
  for k, v of data
    data[k] = (validator.escape v)#.replace /\n/g, '<br>'
  data

module.exports = (io)->
  io.sockets.on 'connection', (socket) ->
    userId = socket.handshake.session.currentUserId
    
    return unless userId

    socket.handshake.session.userId = userId
    
    models.User.find(
      where: { id: userId }
      include: [ {model:models.Space}]
    ).complete (err, user) ->
      return console.console.log(err) if err
      for space in user.spaces
        socket.join space.spaceKey

      console.log "user #{userId} joined #{user.spaces.length} collections"

      socket.on 'newElement',   (data) -> elementController.newElement io, socket, clean(data), errorHandler
      socket.on 'removeElement', (data) -> elementController.removeElement io, socket, clean(data), errorHandler
      socket.on 'updateElement', (data) -> elementController.updateElement io, socket, data, errorHandler
      socket.on 'renameCover', (data) -> elementController.renameCover io, socket, data, errorHandler
      socket.on 'moveToCollection', (data) -> elementController.moveToCollection io, socket, clean(data), errorHandler
      socket.on 'reorderElements', (data) -> spaceController.reorderElements io, socket, clean(data), errorHandler
      socket.on 'newCollection', (data) -> spaceController.newCollection io, socket, clean(data), errorHandler

      # socket.on 'updateSpace', (data) -> spaceController.updateSpace io, socket, clean(data), errorHandler
      # socket.on 'addUserToSpace', (data) -> spaceController.addUserToSpace io, socket, clean(data), errorHandler
      # socket.on 'removeUserFromSpace',(data) -> spaceController.removeUserFromSpace io, socket, clean(data), errorHandler

      socket.on 'disconnect', ->
        console.log 'Client Disconnected.'
