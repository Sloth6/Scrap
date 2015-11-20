$ ->

  socket = io.connect()

  # deleting a user from a collection
  $('.deletable-user').on 'click', (event) ->
    event.preventDefault()
    id = $(this).data 'id'
    socket.emit 'removeUserFromCollection', { id }
