window.collectionController =
  init: ($collections) ->
    $collections.find('.collectionSettings').hide().css('position', 'absolute')
    styleUtilities.transformOrigin $collections.find('.collectionSettings'), 'center', 'center'
    
    $collections.each ->
      $collection = $(@)
      
      collectionView.init $collection
      
      # True if user is doing something in collection settings UI
      $collection.data('settingsInUse', false)
      
      # Store actual height
      collectionController.updateHeight $collection
      
      $collection.zIndex(2)

      # Main click event
      $collection.find('.contents > a').on 'touchend mouseup', (event) ->
        event.stopPropagation()
        event.preventDefault()
        unless $collection.hasClass 'openMenuButton'
          scrapState.waitToOpenCollectionsMenu = true
          collectionKey = $collection.data('collectionkey')
          containerView.switchToCollection collectionKey
          collectionsMenuView.close()
          scrapState.waitToOpenCollectionsMenu = false
      $collection.css
        width: $(@).width()
      
      $collection.find('.contents > a').mouseenter ->
        collectionView.mouseenter $collection
        # If that collection is open and the menu is not open
        if $collection.hasClass('openMenuButton')
          unless scrapState.collectionsMenuIsOpen
            collectionView.showSettings $collection
            
      $collection.find('.contents > a').mouseleave (event) ->
        collectionView.mouseleave $collection, event
      
      $collection.find('.contents').mouseleave ->
        # If that collection is open and the menu is not open
        if $collection.hasClass('openMenuButton')
          unless scrapState.collectionsMenuIsOpen or $collection.data('settingsInUse')
            collectionView.hideSettings $collection
      

  updateHeight: ($collection) ->
    $collection.data 'nativeHeight', Math.max($collection.find('.contents > a').height(), $collection.find('.contents > input').height())
      