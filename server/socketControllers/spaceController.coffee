models = require '../../models'
mail = require '../adapters/nodemailer'
newSpace = require '../newSpace'
async = require 'async'
newElements = require './newElements'
coverColor = require '../modules/coverColor'

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

      # the stack should be emptied
      # sio.to(spaceKey).emit 'removeStack', { id: space.id }
      
    # models.sequelize.query(q2, null, null, { spaceKey }).complete (err, results) ->
    #   return callback err if err?
    #   console.log results

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
        newSpace { UserId: userId }, cb

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
          content: JSON.stringify {
                      spaceKey: newSpace.spaceKey
                      backgroundColor: coverColor()
                    }
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
