makeDeletable = (elems) ->
  elems.each () ->
    elem = $(@)
    elementId = elem.attr 'id'
    spaceKey  = elem.data 'spacekey'

    elem.find('.elementDeleteButton').click () ->
      parentSpaceKey = spacePath[1]
      socket.emit 'removeElement', { elementId, spaceKey, parentSpaceKey }
      # collectionRealign()