onDelete = (elem) ->
  # if (confirm "Delete?")
  elementId = elem.attr 'id'
  spaceKey = elem.parent().parent().data 'spacekey'
  console.log spaceKey
  socket.emit 'removeElement', { elementId, spaceKey }

makeDeletable = (elem) ->
  elem.find('.elementDeleteButton').click () -> onDelete elem

$ ->
  $('.element').each () -> makeDeletable($(@))