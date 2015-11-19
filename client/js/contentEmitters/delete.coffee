onDelete = ($content) ->
  if $content.hasClass('collection')
    if confirm('Delete everything?')
      spaceKey = collectionModel.getState($content).spaceKey
      parentSpaceKey = spacePath[1]  
      socket.emit 'deleteCollection', { spaceKey }
  else
    elementId = $content.attr 'id'
    $collection = contentModel.getCollection $content
    spaceKey  = $collection.data 'spacekey'
    parentSpaceKey = spacePath[1]
    socket.emit 'removeElement', { elementId, spaceKey, parentSpaceKey }

makeDeletable = ($content) ->
  $content.each () ->
    $(@).find('.elementDeleteButton').click (event) =>
      event.stopPropagation()
      onDelete $(@)