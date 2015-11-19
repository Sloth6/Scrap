models = require '../../models'
mail = require '../adapters/nodemailer'
newSpace = require '../newSpace'
async = require 'async'
coverColor = require '../modules/coverColor'
addUserToSpace = require '../addUserToSpace'
collectionRenderer = require '../modules/collectionRenderer'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

module.exports =
  reorderElements: (sio, socket, data) ->
    { spaceKey, elementOrder } = data
    elementOrder = JSON.parse elementOrder
    # console.log elementOrder
    models.Space.update({ elementOrder }, { spaceKey }).complete (err) ->
      console.log(err) if err?

  rename: (sio, socket, data, callback) ->
    { spaceKey, name } = data
    models.Space.update({ name }, { spaceKey }).complete (err) ->
      return callback err if err?
      console.log "updated name of #{spaceKey} to #{name}"
        # sio.to("#{spaceKey}").emit 'updateElement', data
  
  addUserToSpace: (sio, socket, data, callback) =>
    { email, spaceKey } = data
    console.log "Inviting #{email} to #{spaceKey}"
    return callback('invalid') unless email?
    return callback('invalid') unless spaceKey?
    complete = (err, html, space) ->
      domain = 'http://tryScrap.com'
      title = "<a href=\"#{domain}s/#{spaceKey}\">#{space.name}</a>"
      subject = "#you were invited to #{space.name} on Scrap."
      
      html = "
          <h1>View #{title} on Scrap.</h1>
          <p>If you do not yet have an account, register with email '#{email}' to view.</p><br>
          <p><a href=\"#{domain}\">Scrap</a> is a simple visual organization tool.</p>"
      mail.send { to: email, subject: subject, text: html, html: html }
      sio.to(spaceKey).emit 'newElement', { html, spaceKey }

    models.User.find( where: { email }).success (user) ->
      return callback(err) if err?
      return addUserToSpace(user, spaceKey, complete) if user?
      models.User.create({ email, name:email }).complete (err, user) ->
        return callback err if err?
        firstSpaceOptions = { UserId: user.id, name: user.name, root: true }
        newSpace firstSpaceOptions, (err) ->
          return callback err if err?
          addUserToSpace(user, spaceKey, complete) if user?

  newCollection: (sio, socket, data) ->
    # SpaceKey will be the parent of the new collection
    spaceKey = data.spaceKey
    userId   = socket.handshake.session.userId
    # Dragged and draggedOver and the elements that created the collection
    draggedId     = parseInt data.draggedId
    draggedOverId = parseInt data.draggedOverId
    
    console.log 'New collection data', data
    return console.log('no draggedId in newCollection') unless draggedId?
    return console.log('no draggedOverId in newCollection') unless draggedOverId?


    async.waterfall [
      # Get the parent space
      (newSpace, cb) -> models.Space.find( where: { spaceKey } ).complete cb

      # Create the new space
      (parent, cb) -> newSpace { UserId: userId, hasCover:false, parent }, cb

      # Move elements to the new space
      (newSpace, cb) -> 
        console.log 'Moving elements to the new space'
        updateQuery = "UPDATE \"Elements\"
                      SET \"SpaceId\" = '#{newSpace.id}'
                      WHERE id = #{draggedId} or id = #{draggedOverId};
                      "
        newSpace.elementOrder = [draggedId, draggedOverId]
        newSpace.save().complete (err) ->
          return cb(err) if err 
          models.sequelize.query(updateQuery).complete (err) ->
            if err then cb err else cb null, newSpace

      # # Change element order
      # (parentSpace, cover, cb) ->
      #   console.log "Changing element order"
      #   order = parentSpace.elementOrder
      #   console.log "\told element order:", order
      #   console.log "\tcover id:", cover.id
      #   # The position of the dragegdOverId becomes the cover id
        
      #   draggedOverPosition = order.indexOf(draggedOverId)
      #   draggedPosition = order.indexOf(draggedId)

      #   console.log '\tdraggedover index:', draggedOverPosition
      #   console.log  "\tdragged position:", draggedPosition

      #   order[draggedOverPosition] = cover.id
      #   order.splice(draggedPosition, 1)
        
      #   console.log "\t new order",order

      #   parentSpace.save().complete (err) ->
      #     if err then cb err else cb null, parentSpace, cover
    
    ], (err, parentSpace, cover) ->
      return console.log err if err
      
      coverHTML = collectionRenderer(parentSpace)
      sio.to("#{spaceKey}").emit 'newCollection', {coverHTML, draggedId, draggedOverId}
      console.log 'Adding user to room', spaceKey
      socket.join spaceKey

  newPack: (sio, socket, data) ->
    { name } = data
    userId = socket.handshake.session.userId
    return console.log('no userid', res) unless userId?
    return console.log('no name sent', res) unless name?
    console.log 'New pack', { name, userId }
    
    async.waterfall [
      # Get the parent space
      (cb) ->
        models.Space.find( where: { UserId:userId, root: true } ).complete cb

      # Create the new space
      (parent, cb) -> 
        newSpace { UserId: userId, name, hasCover:true, parent }, cb

    ], (err, space) ->
      console.log 'err', err
      return callback(err) if err?
      coverHTML = collectionRenderer(space)
      socket.emit 'newPack', { coverHTML }
      console.log 'Adding user to room', space.spaceKey
      socket.join space.spaceKey

  deleteCollection: (sio, socket, data) ->
    spaceKey = data.spaceKey
    models.Space.find({
      where: { spaceKey }, include:[ model:models.Space, as: "parent" ]
    }).complete (err, space) ->
      parentSpaceKey = space.parent.spaceKey
      space.destroy().complete (err) ->
        console.log 'delete', err
        sio.to("#{parentSpaceKey}").emit 'deleteCollection', { spaceKey }
