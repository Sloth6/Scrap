models = require '../../models'
mail = require '../adapters/nodemailer'
async = require 'async'
coverColor = require '../modules/coverColor'
collectionRenderer = require '../modules/collectionRenderer'
inviteEmail = require '../modules/inviteEmail'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

module.exports =
  reorderArticles: (sio, socket, data) ->
    { collectionKey, articleOrder } = data
    what = { articleOrder }
    models.Collection.update(what, where:{ collectionKey }).done () ->
      console.log 'Emit order to client'
      # sio.to("#{parentCollectionKey}").emit 'newCollection', emitData

  rename: (sio, socket, data, callback) ->
    { collectionKey, name } = data
    models.Collection.update({ name }, where: { collectionKey }).then () ->
      console.log "updated name of #{collectionKey} to #{name}"
      callback null
        # sio.to("#{collectionKey}").emit 'updateArticle', data
  
  inviteToCollection: (sio, socket, data, callback) =>
    { email, collectionKey } = data
    console.log "Inviting #{email} to #{collectionKey}"
    return callback('invalid email') unless email?
    return callback('invalid collectionKey') unless collectionKey?
    
    done = (user, collection) ->
      collection.addUser(user).done (err) ->
        return callback(err) if err?
        { html, subject } = inviteEmail user, collection
        mail.send { to: email, subject: subject, text: html, html: html }
        callback null

    params = 
      where: { collectionKey }
      include: [
        { model: models.User, as: 'Creator' },
        { model: models.User }
      ]

    models.Collection.find( params ).done (err, collection) ->
      return callback(err) if err?
      return callback('cannot invite to stack') unless collection.hasCover
      models.User.find( where: { email }).done (err, user) ->
        return callback(err) if err?
        return done user, collection if user?
        # Else no user
        console.log "\tCreating new user"
        models.User.createAndInitialize { email, name:email }, (err, user) ->
          return callback(err) if err?
          done user, collection

  newStack: (sio, socket, data, callback) ->
    # CollectionKey will be the parent of the new collection
    parentCollectionKey = data.collectionKey
    userId = socket.handshake.session.userId
    
    # Dragged and draggedOver and the articles that created the collection
    draggedId     = parseInt data.draggedId
    draggedOverId = parseInt data.draggedOverId
    
    console.log 'New collection data', data
    return console.log('no draggedId in newCollection') unless draggedId?
    return console.log('no draggedOverId in newCollection') unless draggedOverId?


    async.waterfall [
      # Get the parent collection
      (cb) ->
        options =
          where: { collectionKey: parentCollectionKey }
          include: [ model: models.User, as: 'Creator' ]
        models.Collection.find( options ).done cb

      # Create the new collection
      (parent, cb) ->
        user = parent.Creator
        options = { hasCover: false, CreatorId: userId }
        models.Collection.createAndInitialize options, user, parent, (err, collection) ->
          return cb(err) if err?
          return cb null, collection, parent

      # Move articles to the new collection
      (collection, parent, cb) -> 
        console.log 'Moving articles to the new collection'
        updateQuery = "UPDATE \"Articles\"
                      SET \"CollectionId\" = '#{collection.id}'
                      WHERE id = #{draggedId} or id = #{draggedOverId};
                      "
        collection.articleOrder = [draggedId, draggedOverId]
        collection.save().done (err) ->
          return cb(err) if err 
          models.sequelize.query(updateQuery).done (err) ->
            if err then cb err else cb null, collection, parent

      # Change article order
      (collection, parent, cb) ->
        console.log "Changing article order"
        order = parent.articleOrder
        # The position of the dragegdOverId becomes the cover id   
        draggedOverPosition = order.indexOf(draggedOverId)
        draggedPosition = order.indexOf(draggedId)
        order[draggedOverPosition] = collection.id
        order.splice(draggedPosition, 1)
        parent.save().done (err) ->
          return cb(err) if err?
          cb null, parent, collection
    
    ], (err, parent, collection) ->
      return console.log err if err
      
      collectionHTML = collectionRenderer(collection)
      emitData = {collectionHTML, draggedId, draggedOverId}
      sio.to("#{parentCollectionKey}").emit 'newCollection', emitData
      socket.join collection.collectionKey
      callback null

  newPack: (sio, socket, data, callback) ->
    { name } = data
    userId = socket.handshake.session.userId
    return console.log('no userid', res) unless userId?
    return console.log('no name sent', res) unless name?
    async.waterfall [
      # Get the parent collection
      (cb) ->
        options =
          where: { CreatorId:userId, root: true }
          include: [ model: models.User, as: 'Creator' ]
        models.Collection.find( options ).done cb
      
      # Create the new collection
      (parent, cb) ->
        user = parent.Creator
        options = { name, hasCover:true, CreatorId: userId }
        models.Collection.createAndInitialize options, user, parent, cb

    ], (err, collection) ->
      return callback(err) if err?
      console.log 'new pack', collection.collectionKey
      socket.emit 'newPack', { collectionHTML: collectionRenderer(collection) }
      socket.join collection.collectionKey
      callback null

  deleteCollection: (sio, socket, data, callback) ->
    collectionKey = data.collectionKey
    models.Collection.find({
      where: { collectionKey }, include:[ model:models.Collection, as: "parent" ]
    }).then ( collection) ->
      parentCollectionKey = collection.parent.collectionKey

      # TODO change location string of parent
      # draggedPosition = order.indexOf(draggedId)
      # order.splice(draggedPosition, 1)

      collection.destroy().done (err) ->
        sio.to("#{parentCollectionKey}").emit 'deleteCollection', { collectionKey }
        callback null
