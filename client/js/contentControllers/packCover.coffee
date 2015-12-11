addUser = (email, collectionKey) ->
  console.log "inviting #{email} to #{collectionKey}"
  socket.emit 'inviteToCollection', { email, collectionKey }

stopEditing = ($cover) ->
  return unless $cover.hasClass('editing')
  collectionKey = $cover.parent().data 'collectionkey'
  $title        = $cover.find('.collectionTitle')
  $card         = $cover.find('.card')
  $renameButton = $cover.find('.rename')
  $userMenu     = $card.find('ul.menu')

  $cover.removeClass  'editing'
  $cover.addClass     'colored'
  $card.removeClass   'editing'
  $card.removeClass   'hover'
  $renameButton.css('opacity', '')
  
  # Make user menu accessible after renaming
  $userMenu.addClass 'canOpen'
  $renameButton.children('a').text 'Rename'
  $title.attr 'contenteditable', false
  socket.emit 'renameCover', { collectionKey, name: $title.text() }

startEditing = ($cover) ->
  collectionKey   = $cover.parent().data 'collectionkey'
  $title          = $cover.find('.collectionTitle')
  $card           = $cover.find('.card')
  $renameButton   = $cover.find('.rename')
  $userMenu       = $card.find('ul.menu')

  $cover.addClass 'editing'
  $cover.removeClass 'colored'
  $card.addClass 'editing'
  $card.addClass 'hover'
  $renameButton.css('opacity', '1')
    
  # Make user menu inaccessible during renaming
  $userMenu.removeClass 'canOpen'
  $userMenu.removeClass 'open'

  $renameButton.children('a').text 'Save'
  $title.attr('contenteditable', true).focus()
  # $title.blur () ->
  #   console.log 'blur'
  #   stopEditing $cover, $title
  $cover.keypress (e) ->
    if e.which == 13
      stopEditing $cover, $title
      false

coverClick = (event) ->
  if $(@).hasClass('editing')
    event.stopPropagation()

packCoverInit = ($cover, collectionKey) ->
  console.log 'pack cover init'
  $card             = $cover.find('.card')
  $userMenu         = $cover.find('.menu')
  $renameButton     = $cover.find('.rename')
  $addUserForm      = $userMenu.find('form.addUser')
  $noticeField      = $userMenu.find('.notice')
  $userListLabel    = $userMenu.find('li.user label')
  $instructionLabel = $userMenu.find('label.instruction')
  $submitButton     = $userMenu.find('input[type=submit]')
  $emailInput       = $userMenu.find('input[name="user[email]"]')

  $cover.click coverClick
        
  # Renaming covers
  $renameButton.find('a').click (event) ->
    event.stopPropagation()
    if $cover.hasClass('editing') then stopEditing $cover else startEditing $cover
  # Submitting new user
  $submitButton.css 'opacity', 0
  $noticeField.css  'opacity', 0
  $emailInput.on 'focus', (event) ->
    # Show submit button on email field focus
    $submitButton.velocity
      opacity: 1
    $cover.data 'canCloseMenu', true
  $emailInput.on 'blur', (event) ->
    # If no email entered yet, hide button
    if $emailInput.val() is ''
      $submitButton.velocity
        opacity: 0
      $cover.data 'canCloseMenu', false
      $userMenu.removeClass 'open'
  $addUserForm.on 'submit', (event) ->
    email = $emailInput.val()
    event.preventDefault()
    # Display notice
    if !validateEmail(email)
      # Invalid
      $noticeField.html 'Please enter a valid email address'
    else
      # Add user
      $emailInput.val ''
      $('<li>').
        addClass('user').
        text(email).
        insertBefore $cover.find('.user.add')
      $userListLabel.removeClass 'invisible'
      $noticeField.html "Shared with #{email}" 
      $cover.data 'canCloseMenu', false
      addUser email, collectionKey
    # Toggle label visibility after changing text
    $instructionLabel.velocity
      opacity: 0
    $noticeField.velocity
      opacity: 1
    # Reset notice
    setTimeout (() -> 
      $instructionLabel.velocity
        opacity: 1
      $noticeField.velocity
        properties:
          opacity: 0
        options:
          complete: () ->
            $noticeField.html '' 
    ), 2000
      
  # Open/close user menu  
  $card.mouseover () -> $userMenu.addClass    'open'
  $card.mouseout  () -> $userMenu.removeClass 'open' unless $cover.data('canCloseMenu')

  # dont open collection on clicking user field
  $cover.find('.addUser input[name="user[email]"]').click (event) ->
    event.stopPropagation()

  # dont open collection on submit
  $cover.find('.addUser input:submit').click (event) ->
    event.stopPropagation()
