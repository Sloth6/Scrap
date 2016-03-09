window.collectionController =
  init: ($collections) ->
    $collections.find('.collectionSettings').hide().css('position', 'absolute')
    styleUtilities.transformOrigin $collections.find('.collectionSettings'), 'center', 'center'

    $collections.each () ->
      $collection = $(@)
      $a          = $collection.find('.contents > a')
      $contents   = $collection.find('.contents')

      collectionView.init $collection

      $collection.css
        width: $(@).width()
        zIndex: 2

      # True if user is doing something in collection settings UI
      $collection.data('settingsInUse', false)

      # Store actual height
      collectionController.updateHeight $collection

      # Main click event
      $a.on 'touchend mouseup', (event) ->
        collectionController.click($collection, event)

      $a.on 'touchstart mouseenter', (event) ->
        collectionController.mouseenter $collection, event

      $a.on 'touchend mouseleave', (event) ->
        collectionController.mouseleave $collection, event

      $contents.mouseleave (event) ->
        collectionController.hideSettings $collection

  updateHeight: ($collection) ->
    $collection.data 'nativeHeight', Math.max($collection.find('.contents > a').height(), $collection.find('.contents > input').height())

  click: ($collection, event) ->
    if $collection.hasClass 'openMenuButton'
      scrapState.waitToOpenCollectionsMenu = true
      collectionsMenuView.open(event)
    else
      scrapState.waitToOpenCollectionsMenu = true
      collectionKey = $collection.data('collectionkey')
      containerView.switchToCollection collectionKey
      collectionsMenuView.close()
      scrapState.waitToOpenCollectionsMenu = false
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
