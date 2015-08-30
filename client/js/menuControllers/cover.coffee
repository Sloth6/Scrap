validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test(email)

addUser = (email, spaceKey) ->
  console.log "inviting #{email} to #{spaceKey}"
  
  $.post '/addUserToSpace', { email, spaceKey }, (data) ->
    console.log 'success', data

  # socket.emit 'addUserToSpace', { email, spaceKey }

$ ->
  
  # dont open collection on clicking user field
  $('.addUser input[name="user[email]"]').click (event) ->
    event.stopPropagation()

  # dont open collection on submit
  $('.addUser input:submit').click (event) ->
    event.stopPropagation()

  # submit on enter
  $('.addUser').on 'submit', (event) ->
    event.preventDefault()
    spaceKey = $(@).data 'spacekey'
    input = $('input[name="user[email]"]', @)
    textField = $(@).children('label')
    
    email = input.val()

    if !validateEmail(email) 
      textField.html 'Please enter a valid email'
    else
      input.val ''
      textField.html 'An invite has been sent'
      addUser email, spaceKey

  $('.cover ul.menu').each () ->
    $menu = $(@)
    $cover = $menu.parent().parent('.cover')
    # $cover.mouseenter () ->
    #   $menu.addClass 'open'
    # $cover.mouseleave () ->
    #   $menu.removeClass 'open'