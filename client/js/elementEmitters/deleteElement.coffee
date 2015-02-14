onDelete = () ->
  window.dontAddNext = true
  # if (confirm "Delete?")
  elementId = $(@).parent().parent().attr 'id'
  detach $(@).parent()
  socket.emit 'removeElement', { elementId, userId }

makeDeletable = (elem) ->
  elem.find('a.delete').mouseup onDelete

$ ->
  socket = io.connect()
  $("article a.delete").mouseup onDelete

