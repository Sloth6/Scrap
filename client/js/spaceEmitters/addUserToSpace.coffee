# $ ->

#   socket = io.connect()

#   # adding a user to a collection
#   $('.add-user').on 'submit', (event) ->
#     event.preventDefault()
#     email = $('input[name="user[email]"]', this).val()
#     $('input[name="user[email]"]', this).val('')
#     socket.emit 'addUserToCollection', { email, name: window.username }
