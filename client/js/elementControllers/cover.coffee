validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test(email)

addUser = (email, spaceKey) ->
  console.log "inviting #{email} to #{spaceKey}"
  # $.post '/addUserToSpace', { email, spaceKey }, (data) ->
  #   console.log 'success', data
  socket.emit 'addUserToSpace', { email, spaceKey }

stopEditing = (cover) ->
  return unless cover.hasClass('editing')
  title  = cover.find('.collectionTitle')
  card   = cover.children('.card')
  spaceKey = cover.data('content').spaceKey
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
    spaceKey = $(@).data('content').spaceKey
    history.pushState { name: spaceKey }, "", "/s/#{spaceKey}"
    collectionOpen $(@)

bindCoverControls = (covers) ->
  # console.log covers
  covers.click coverClick
  covers.each () ->
    cover  = $(@)
    rename = cover.find('.rename')
    rename.find('a').click (event) ->
      event.stopPropagation()
      if cover.hasClass('editing') then stopEditing cover else startEditing cover
  

    # submit on enter
    cover.find('.addUser').on 'submit', (event) ->
      event.preventDefault()
      spaceKey = cover.data('content').spaceKey
      input = $('input[name="user[email]"]', @)
      textField = $(@).children('label')
      
      email = input.val()
      if !validateEmail(email) 
        textField.html 'Please enter a valid email'
      else
        input.val ''
        textField.html 'An invite has been sent'
        addUser email, spaceKey
        
  # dont open collection on clicking user field
  covers.find('.addUser input[name="user[email]"]').click (event) ->
    event.stopPropagation()

  # dont open collection on submit
  covers.find('.addUser input:submit').click (event) ->
    event.stopPropagation()
 
  covers.find('ul.menu').each () ->
    $menu = $(@)
    $cover = $menu.parent().parent('.cover')

    $cover.mouseenter () ->
      $menu.addClass 'open' if $menu.hasClass 'canOpen'
    $cover.mouseleave () ->
      $menu.removeClass 'open' if $menu.hasClass 'canOpen'

coverInit = (covers) ->
  projectInit = (project, data) ->
    cover.find('section.title').children('h1, h2, h3').text data.name
    bindCoverControls project
    for u in data.users
      name = u.name or u.email
      cover.find('ul.users').prepend "<li class='user'>#{name}</li>"

  stackInit = (cover, data) ->
    stack = stackCreate cover
    # stack.css {
    #   'background-color': 'red'
    #   width: 300
    #   height: 300
    # }

    stackPopulate stack
    stack.click () ->
      stack.empty()
      coverClick.call $(@)

  covers.each () ->
    $.get "/collectionData/#{$(@).data('content').spaceKey}", (data) =>
      if true then stackInit($(@), data) else projectInit $(@), data

# $ ->
#   coverInit $('.cover')
