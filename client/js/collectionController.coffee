window.collectionController =
  init: ($collections) ->
    $collections.find('.collectionSettings').hide().css('position', 'absolute')
    styleUtilities.transformOrigin $collections.find('.collectionSettings'), 'center', 'center'

    $collections.each () ->
      $collection = $(@)
      $a          = $collection.find('.contents > a')
      $contents   = $collection.find('.contents')
      $actions    = $collection.find('.actions')

      collectionView.init $collection

      $collection.data 'offsetTop', $collection.offset().top

      $collection.css
        width: $(@).width()
        zIndex: 2

      # Store actual height
      collectionController.updateHeight $collection

      # True if collection settings UI is in use
      $collection.data 'settingsInUse', false

      popController.init $a, 250, 1.25

      # Main click event
      $a.on 'touchend mouseup', (event) ->
        collectionController.click($collection, event)

      $a.on 'touchstart mouseenter', (event) ->
        collectionController.mouseenter $collection, event

      $a.on 'touchend mouseleave', (event) ->
        collectionController.mouseleave $collection, event

      $contents.on 'touchend mouseleave', (event) ->
        collectionController.hideSettings $collection

      $contents.on 'touchmove mousemove', (event) ->
        collectionController.contentsMove $collection

      # Collection Settings.
      $settings = $collection.find '.collectionSettings'
      # $settings.find('input.addSomeone').on 'touchend mouseup', (event) ->
      #   collectionView.openAddUserForm $collection

      # console.log $settings.find('.add form')
      $settings.find('.add form').show().css opacity: 1
      $settings.find('.add form').submit (event) ->
        collectionController.addUserSubmit $collection
        event.preventDefault()

      $settings.find('input.rename').on 'touchend mouseup', (event) ->
        collectionController.rename $collection

      $settings.find('input.delete').on 'touchend mouseup', (event) ->
        collectionController.delete $collection

      $settings.find('input').on 'touchend mouseup', (event) ->
        event.preventDefault()
        event.stopPropagation()

      # Make settings hide-able if user blurs email input
      # $settings.find('input[type=email]').blur ->
      #   $collection.data 'settingsInUse', false
      #   $('body').mousemove ->
      #     unless $collection.is('.hover')
      #       $collection.find('.contents > a').trigger 'mouseleave'

      # $settings.find('.actions input[type=button]').on 'touchend mouseup', (event) ->
      #   event.stopPropagation()
      #   $collection.data 'settingsInUse', true
      #   alert 'Confirmation UI goes here'
        # After completing dialog
        # $collection.data 'settingsInUse', false

  rename: ($collection) ->
    collectionKey = $collection.data 'collectionkey'
    $a = $collection.find('.contents a')
    $a.prop 'contenteditable', true
    $a.addClass 'contenteditable'
    $a.focus()

    done = () ->
      name = $a.text()
      $a.removeClass 'contenteditable'
      $a.prop 'contenteditable', false
      $a.off 'keypress focusout'
      $a.blur()
      # change name on article collections
      $("article .collection.#{collectionKey} a").text name
      socket.emit 'renameCollection', {collectionKey, name}

    $a.keypress (event) ->
      if(event.which == 13)
        event.preventDefault()
        done()

    $a.focusout (event) ->
      done()

  delete: ($collection) ->
    collectionKey = $collection.data 'collectionkey'
    socket.emit 'removeCollection', { collectionKey }

    # This removes all labels on articles and in menu
    $(".collection.#{collectionKey}").remove()

    if window.openCollection == collectionKey
      containerView.switchToCollection 'recent'

  addUserSubmit: ($collection) ->
    input         = $collection.find('input[type=email]')
    email         = input.val()
    collectionKey = $collection.data 'collectionkey'

    if !email or !collectionKey
      console.log {email, collectionKey}
      throw 'invalid addUser params'

    collectionView.addUser $collection, email
    socket.emit 'inviteToCollection', { email, collectionKey }

  updateHeight: ($collection) ->
    $collection.data 'nativeHeight', Math.max($collection.find('.contents > a').height(), $collection.find('.contents > input').height())

  click: ($collection, event) ->
    if $collection.hasClass 'openMenuButton'
      collectionsMenuController.open $(constants.dom.collectionsMenu), $collection, event
    else
      collectionKey = $collection.data('collectionkey')
      containerView.switchToCollection collectionKey
      collectionsMenuView.close()
    event.stopPropagation()
    event.preventDefault()

  mouseenter: ($collection, event) ->
    cursorView.end()
    # If that collection is open and the menu is not open
    if $collection.hasClass('openMenuButton')
      unless scrapState.collectionsMenuIsOpen
        collectionView.showSettings $collection

  mouseleave: ($collection, event) ->
    cursorView.start '✕', event

  hideSettings: ($collection) ->
    # If that collection is open and the menu is not open
    if $collection.hasClass('openMenuButton')
      unless scrapState.collectionsMenuIsOpen or $collection.data('settingsInUse')
        collectionView.hideSettings $collection

  contentsMove: ($collection) ->
    # Regular cursor on settings
    cursorView.end()
