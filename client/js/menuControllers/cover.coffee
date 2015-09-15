validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test(email)

addUser = (email, spaceKey) ->
  console.log "inviting #{email} to #{spaceKey}"
  
  $.post '/addUserToSpace', { email, spaceKey }, (data) ->
    console.log 'success', data

  # socket.emit 'addUserToSpace', { email, spaceKey }

stopEditing = (cover) ->
  return unless cover.hasClass('editing')
  title  = cover.find('.collectionTitle')
  card   = cover.children('.card')
  spaceKey = cover.data 'spacekey'
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
  socket.emit 'renameCover', { elemId: cover.attr('id'), name: title.text() }

startEditing = (cover) ->
  title  = cover.find('.collectionTitle')
  card   = cover.children('.card')
  spaceKey = cover.data 'spacekey'
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
#   setTimeout( () ->
#     userMenu.css('display', 'none')
#   , 1000)

  rename.children('a').text 'Save'
  title.attr('contenteditable', true).focus()
  # title.blur () ->
  #   console.log 'blur'
  #   stopEditing cover, title
  cover.keypress (e) ->
    if e.which == 13
      stopEditing cover, title
      false

coverClick = () ->
  return if $(@).hasClass 'dragging'
  if $(@).hasClass 'open'
    $(window).scrollLeft 0
    collectionRealign.call $('.slidingContainer')
  else if !$(@).hasClass('editing')
    spaceKey = $(@).data 'spacekey'
    history.pushState { name: spaceKey }, "", "/s/#{spaceKey}"
    collectionOpen $(@)

bindCoverControls = (covers) ->
  covers.click coverClick
  covers.each () ->
    cover  = $(@)
    rename = cover.find('.rename')
    rename.find('a').click (event) ->
      event.stopPropagation()
      if cover.hasClass('editing') then stopEditing cover else startEditing cover
  
  # dont open collection on clicking user field
  covers.find('.addUser input[name="user[email]"]').click (event) ->
    event.stopPropagation()

  # dont open collection on submit
  covers.find('.addUser input:submit').click (event) ->
    event.stopPropagation()

  # submit on enter
  covers.find('.addUser').on 'submit', (event) ->
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
      
  covers.find('ul.menu').each () ->
    $menu = $(@)
    $cover = $menu.parent().parent('.cover')

    $cover.mouseenter () ->
      $menu.addClass 'open' if $menu.hasClass 'canOpen'
    $cover.mouseleave () ->
      $menu.removeClass 'open' if $menu.hasClass 'canOpen'
$ ->
  bindCoverControls $('.cover')
      