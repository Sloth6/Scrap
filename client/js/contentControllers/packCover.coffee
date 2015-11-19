addUser = (email, spaceKey) ->
  console.log "inviting #{email} to #{spaceKey}"
  socket.emit 'addUserToSpace', { email, spaceKey }

stopEditing = (cover) ->
  return unless cover.hasClass('editing')
  title  = cover.find('.collectionTitle')
  card   = cover.find('.card')
  spaceKey = cover.parent().data 'spacekey'
  rename   = cover.find('.rename')
  userMenu = card.find('ul.menu')

  cover.removeClass 'editing'
  cover.addClass 'colored'
  card.removeClass 'editing'
  card.removeClass 'hover'
  rename.css('opacity', '')
  
  # Make user menu accessible after renaming
  userMenu.addClass 'canOpen'
  rename.children('a').text 'Rename'
  title.attr 'contenteditable', false
  socket.emit 'renameCover', { spaceKey, name: title.text() }

startEditing = (cover) ->
  title  = cover.find('.collectionTitle')
  card   = cover.find('.card')
  spaceKey = cover.parent().data 'spacekey'
  rename   = cover.find('.rename')
  userMenu = card.find('ul.menu')

  cover.addClass 'editing'
  cover.removeClass 'colored'
  card.addClass 'editing'
  card.addClass 'hover'
  rename.css('opacity', '1')
    
  # Make user menu inaccessible during renaming
  userMenu.removeClass 'canOpen'
  userMenu.removeClass 'open'

  rename.children('a').text 'Save'
  title.attr('contenteditable', true).focus()
  # title.blur () ->
  #   console.log 'blur'
  #   stopEditing cover, title
  cover.keypress (e) ->
    if e.which == 13
      stopEditing cover, title
      false

coverClick = (event) ->
  # navigationController.goToEnd $collection    
  if $(@).hasClass('editing')
    event.stopPropagation()

bindCoverControls = (cover) ->
  cover.click coverClick

  rename = cover.find('.rename')
  rename.find('a').click (event) ->
    event.stopPropagation()
    if cover.hasClass('editing') then stopEditing cover else startEditing cover
  # submit on enter
  cover.find('.addUser').on 'submit', (event) ->
    event.preventDefault()
    spaceKey = cover.data('content')
    input = $('input[name="user[email]"]', @)
    textField = $(@).children('label')
    
    email = input.val()
    if !validateEmail(email) 
      textField.html 'Please enter a valid email'
    else
      input.val ''
      $('<li>').
        addClass('user').
        text('Joel Simon').
        insertBefore cover.find('.user.add')
      textField.html 'An invite has been sent'
      addUser email, spaceKey
    
    cover.find('ul.menu').each () ->
      cover.mouseenter () => $(@).addClass 'open' if $(@).hasClass 'canOpen'
      cover.mouseleave () => $(@).removeClass 'open' if $(@).hasClass 'canOpen'

  # dont open collection on clicking user field
  cover.find('.addUser input[name="user[email]"]').click (event) ->
    event.stopPropagation()

  # dont open collection on submit
  cover.find('.addUser input:submit').click (event) ->
    event.stopPropagation()

packCoverInit = (cover, data) ->
  # cover.find('section.title').children('h1, h2, h3').text data.name
  bindCoverControls cover
  # cover.find('.card').css 'background-color', data.color
  # for u in data.users
  #   name = u.name or u.email
  #   cover.find('ul.users').prepend "<li class='user'>#{name}</li>"
