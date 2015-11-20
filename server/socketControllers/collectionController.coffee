models = require '../../models'
mail = require '../adapters/nodemailer'
newCollection = require '../newCollection'
async = require 'async'
coverColor = require '../modules/coverColor'
addUserToCollection = require '../addUserToCollection'
collectionRenderer = require '../modules/collectionRenderer'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

module.exports =
  reorderArticles: (sio, socket, data) ->
    { collectionKey, articleOrder } = data
    articleOrder = JSON.parse articleOrder
    # console.log articleOrder
    models.Collection.update({ articleOrder }, { collectionKey }).complete (err) ->
      console.log(err) if err?

  rename: (sio, socket, data, callback) ->
    { collectionKey, name } = data
    models.Collection.update({ name }, { collectionKey }).complete (err) ->
      return callback err if err?
      console.log "updated name of #{collectionKey} to #{name}"
        # sio.to("#{collectionKey}").emit 'updateArticle', data
  
  addUserToCollection: (sio, socket, data, callback) =>
    { email, collectionKey } = data
    console.log "Inviting #{email} to #{collectionKey}"
    return callback('invalid') unless email?
    return callback('invalid') unless collectionKey?
    complete = (err, html, collection) ->
      domain = 'http://tryScrap.com'
      title = "<a href=\"#{domain}s/#{collectionKey}\">#{collection.name}</a>"
      subject = "#you were invited to #{collection.name} on Scrap."
      
      html = "
          <h1>View #{title} on Scrap.</h1>
          <p>If you do not yet have an account, register with email '#{email}' to view.</p><br>
          <p><a href=\"#{domain}\">Scrap</a> is a simple visual organization tool.</p>"
      mail.send { to: email, subject: subject, text: html, html: html }
      sio.to(collectionKey).emit 'newArticle', { html, collectionKey }

    models.User.find( where: { email }).success (user) ->
      return callback(err) if err?
      return addUserToCollection(user, collectionKey, complete) if user?
      models.User.create({ email, name:email }).complete (err, user) ->
        return callback err if err?
        firstCollectionOptions = { UserId: user.id, name: user.name, root: true }
        newCollection firstCollectionOptions, (err) ->
          return callback err if err?
          addUserToCollection(user, collectionKey, complete) if user?

  newCollection: (sio, socket, data) ->
    # CollectionKey will be the parent of the new collection
    collectionKey = data.collectionKey
    userId   = socket.handshake.session.userId
    # Dragged and draggedOver and the articles that created the collection
    draggedId     = parseInt data.draggedId
    draggedOverId = parseInt data.draggedOverId
    
    console.log 'New collection data', data
    return console.log('no draggedId in newCollection') unless draggedId?
    return console.log('no draggedOverId in newCollection') unless draggedOverId?


    async.waterfall [
      # Get the parent collection
      (newCollection, cb) -> models.Collection.find( where: { collectionKey } ).complete cb

      # Create the new collection
      (parent, cb) -> newCollection { UserId: userId, hasCover:false, parent }, cb

      # Move articles to the new collection
      (newCollection, cb) -> 
        console.log 'Moving articles to the new collection'
        updateQuery = "UPDATE \"Articles\"
                      SET \"CollectionId\" = '#{newCollection.id}'
                      WHERE id = #{draggedId} or id = #{draggedOverId};
                      "
        newCollection.articleOrder = [draggedId, draggedOverId]
        newCollection.save().complete (err) ->
          return cb(err) if err 
          models.sequelize.query(updateQuery).complete (err) ->
            if err then cb err else cb null, newCollection

      # # Change article order
      # (parentCollection, cover, cb) ->
      #   console.log "Changing article order"
      #   order = parentCollection.articleOrder
      #   console.log "\told article order:", order
      #   console.log "\tcover id:", cover.id
      #   # The position of the dragegdOverId becomes the cover id
        
      #   draggedOverPosition = order.indexOf(draggedOverId)
      #   draggedPosition = order.indexOf(draggedId)

      #   console.log '\tdraggedover index:', draggedOverPosition
      #   console.log  "\tdragged position:", draggedPosition

      #   order[draggedOverPosition] = cover.id
      #   order.splice(draggedPosition, 1)
        
      #   console.log "\t new order",order

      #   parentCollection.save().complete (err) ->
      #     if err then cb err else cb null, parentCollection, cover
    
    ], (err, parentCollection, cover) ->
      return console.log err if err
      
      coverHTML = collectionRenderer(parentCollection)
      sio.to("#{collectionKey}").emit 'newCollection', {coverHTML, draggedId, draggedOverId}
      console.log 'Adding user to room', collectionKey
      socket.join collectionKey

  newPack: (sio, socket, data) ->
    { name } = data
    userId = socket.handshake.session.userId
    return console.log('no userid', res) unless userId?
    return console.log('no name sent', res) unless name?
    console.log 'New pack', { name, userId }
    
    async.waterfall [
      # Get the parent collection
      (cb) ->
        models.Collection.find( where: { UserId:userId, root: true } ).complete cb

      # Create the new collection
      (parent, cb) -> 
        newCollection { UserId: userId, name, hasCover:true, parent }, cb

    ], (err, collection) ->
      console.log 'err', err
      return callback(err) if err?
      coverHTML = collectionRenderer(collection)
      socket.emit 'newPack', { coverHTML }
      console.log 'Adding user to room', collection.collectionKey
      socket.join collection.collectionKey

  deleteCollection: (sio, socket, data) ->
    collectionKey = data.collectionKey
    models.Collection.find({
      where: { collectionKey }, include:[ model:models.Collection, as: "parent" ]
    }).complete (err, collection) ->
      parentCollectionKey = collection.parent.collectionKey
      collection.destroy().complete (err) ->
        console.log 'delete', err
        sio.to("#{parentCollectionKey}").emit 'deleteCollection', { collectionKey }
