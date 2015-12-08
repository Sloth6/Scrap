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
  # navigationController.goToEnd $collection    
  if $(@).hasClass('editing')
    event.stopPropagation()

packCoverInit = ($cover, collectionKey) ->
  $card             = $cover.find('.card')
  $userMenu         = $cover.find('.menu')
  $addUserForm      = $userMenu.find('form.addUser')
  $renameButton     = $userMenu.find('.rename')
  $noticeField      = $userMenu.find('.notice')
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
    $submitButton.velocity
      opacity: 1
  $emailInput.on 'blur', (event) ->
    $submitButton.velocity
      opacity: 0
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
      $noticeField.html "Shared with #{email}" 
      addUser email, collectionKey
    # Toggle label visibility after changing text
    $instructionLabel.velocity
      opacity: 0
    $noticeField.velocity
      opacity: 1
    # Reset notice
    setTimeout (() -> 
      $noticeField.html "Shared with #{email}" 
      $instructionLabel.velocity
        opacity: 1
      $noticeField.velocity
        opacity: 0
    ), 2000
      
  # Open/close user menu  
  $card.mouseenter () -> $userMenu.addClass    'open'
  $card.mouseleave () -> $userMenu.removeClass 'open'

  # dont open collection on clicking user field
  $cover.find('.addUser input[name="user[email]"]').click (event) ->
    event.stopPropagation()

  # dont open collection on submit
  $cover.find('.addUser input:submit').click (event) ->
    event.stopPropagation()
