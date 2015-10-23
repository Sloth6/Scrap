models = require '../../models'
mail = require '../adapters/nodemailer'
newSpace = require '../newSpace'
async = require 'async'
coverColor = require '../modules/coverColor'
addUserToSpace = require '../addUserToSpace'

element_jade = null
require('fs').readFile __dirname+'/../../views/partials/element.jade', 'utf8', (err, data) ->
  throw err if err
  element_jade = require('jade').compile data

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

module.exports =
  reorderElements: (sio, socket, data) ->
    { spaceKey, elementOrder } = data
    elementOrder = JSON.parse elementOrder
    # console.log elementOrder
    models.Space.update({elementOrder}, {spaceKey}).complete (err) ->
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
    spaceKey = data.spaceKey # SpaceKey will be the parent of the new collection
    draggedId = parseInt data.draggedId
    draggedOverId = parseInt data.draggedOverId
    userId = socket.handshake.session.userId
    console.log 'New collection data', { spaceKey, draggedId, draggedOverId }
    
    # Dragged and draggedOver and the elements that created the collection
    
    async.waterfall [
      # Create the new space
      (cb) ->
        console.log "Creating the new space"
        newSpace { UserId: userId, hasCover:false }, cb

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

      # Get the parent space
      (newSpace, cb) ->
        console.log "Getting parent spaces"
        models.Space.find( where: { spaceKey } ).complete (err, parentSpace) ->
          if err then cb err else cb null, newSpace, parentSpace

      # Create cover element
      (newSpace, parentSpace, cb) ->
        console.log "Creating cover element"
        coverAttributes =
          SpaceId: parentSpace.id
          creatorId: userId
          contentType: 'cover'
          content: newSpace.spaceKey
 
        models.Element.create(coverAttributes).complete (err, cover) ->
          if err then cb err
          newSpace.coverId = cover.id
          newSpace.save().complete (err) ->
            if err then cb err else cb null, parentSpace, cover

      # Change element order
      (parentSpace, cover, cb) ->
        console.log "Changing element order"
        order = parentSpace.elementOrder
        console.log "\told element order:", order
        console.log "\tcover id:", cover.id
        # The position of the dragegdOverId becomes the cover id
        
        draggedOverPosition = order.indexOf(draggedOverId)
        draggedPosition = order.indexOf(draggedId)

        console.log '\tdraggedover index:', draggedOverPosition
        console.log  "\tdragged position:", draggedPosition

        order[draggedOverPosition] = cover.id
        order.splice(draggedPosition, 1)
        
        console.log "\t new order",order

        parentSpace.save().complete (err) ->
          if err then cb err else cb null, parentSpace, cover
    
    ], (err, parentSpace, cover) ->
      return console.log err if err
      
      coverHTML = encodeURIComponent element_jade({
        element: cover, collection: parentSpace
      })

      sio.to("#{spaceKey}").emit 'newCollection', {coverHTML, draggedId, draggedOverId}
      console.log  'Adding user to room', cover.content
      socket.join cover.content

  newPack: (sio, socket, data) ->
    { name } = data
    userId = socket.handshake.session.userId
    return console.log('no userid', res) unless userId?
    return console.log('no name sent', res) unless name?
    console.log 'New pack', { name, userId }
    
    async.waterfall [
      # Create the new space
      (cb) -> 
        newSpace { UserId: userId, name, hasCover:true }, cb
      # Get the parent space
      (newSpace, cb) ->
        console.log  'Get the parent space'
        params = where: { UserId:userId, root: true }
        models.Space.find( params ).complete (err, root) ->
          if err then cb err else cb null, newSpace, root
      # Create cover element
      (newSpace, root, cb) ->
        console.log 'Create cover element'
        coverAttributes =
          SpaceId: root.id
          creatorId: userId
          contentType: 'cover'
          content: newSpace.spaceKey
        models.Element.create(coverAttributes).complete (err, cover) ->
          if err then cb err else cb null, root, cover
      # Change element order
      (root, cover, cb) ->
        root.elementOrder.push cover.id
        root.save().complete (err) ->
          if err then cb err else cb null, root, cover
    ], (err, root, cover) ->
      return callback(err) if err?
      coverHTML = encodeURIComponent element_jade {
        element: cover, collection: root
      }
      socket.emit 'newPack', { coverHTML }
      console.log 'Adding user to room', cover.content
      socket.join cover.content
