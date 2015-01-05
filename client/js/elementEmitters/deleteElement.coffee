$("article a.delete").click () ->
  socket.emit 'removeElement', { elementId }