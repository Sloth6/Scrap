onDelete = () ->
  elementId = $(@).parent().attr 'id'
  console.log elementId
  socket.emit 'removeElement', { elementId }

makeDeletable = (elem) ->
	elem.find('a.delete').click onDelete

$ ->
  socket = io.connect()
  $("article a.delete").click onDelete
