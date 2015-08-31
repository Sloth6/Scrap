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
#   userMenu.css('display', 'block')

  rename.children('a').text 'Rename'

  title.attr 'contenteditable', false
  $.post '/updateSpaceName', { spaceKey, name: title.text() }, () ->
    console.log 'name updated successfully'

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


$ ->
  # Open a collection on click
  $('.cover').click () ->
    if $(@).hasClass 'open'
      $(window).scrollLeft 0
      collectionRealign.call $('.slidingContainer')
    else if !$(@).hasClass('editing')
      spaceKey = $(@).data 'spacekey'
      history.pushState { name: spaceKey }, "", "/s/#{spaceKey}"
      collectionOpen $(@)
      
  $('.cover').each () ->
    cover  = $(@)
    rename = cover.find('.rename')
    rename.find('a').click (event) ->
      event.stopPropagation()
      if cover.hasClass('editing') then stopEditing cover else startEditing cover
  
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

    $cover.mouseenter () ->
      $menu.addClass 'open' if $menu.hasClass 'canOpen'
    $cover.mouseleave () ->
      $menu.removeClass 'open' if $menu.hasClass 'canOpen'