makeDeletable = (elems) ->
  elems.each () ->
    elem = $(@)
    elementId = elem.attr 'id'
    spaceKey  = elem.data 'spacekey'

    elem.find('.elementDeleteButton').click () ->
      socket.emit 'removeElement', { elementId, spaceKey }
      collectionRealign()