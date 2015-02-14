onDelete = () ->
  window.dontAddNext = true
  # if (confirm "Delete?")
  elementId = $(@).parent().parent().attr 'id'
  detach $(@).parent()
  console.log 'delete', elementId, userId

  socket.emit 'removeElement', { elementId, userId }

makeDeletable = (elem) ->
  elem.find('a.delete').click onDelete

$ ->
  socket = io.connect()
  $("article a.delete").click onDelete

