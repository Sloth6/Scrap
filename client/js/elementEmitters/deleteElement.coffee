onDelete = () ->
	window.dontAddNext = true
	if (confirm "Delete?")
	  elementId = $(@).parent().attr 'id'
	 	detach $(@).parent()
	  socket.emit 'removeElement', { elementId, userId }

makeDeletable = (elem) ->
	elem.find('a.delete').click onDelete

$ ->
  socket = io.connect()
  $("article a.delete").click onDelete

