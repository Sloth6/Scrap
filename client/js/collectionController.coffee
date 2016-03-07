window.collectionController =
  init: ($collections) ->
    $collections.find('.collectionSettings').hide().css('position', 'absolute')
    styleUtilities.transformOrigin $collections.find('.collectionSettings'), 'center', 'center'
    
    $collections.each ->
      $collection = $(@)
      
      # Store actual height
      collectionController.updateHeight $collection
      
      $collection.zIndex(2)
      $collection.find('.contents > a').click (event) ->
        unless $collection.hasClass 'openMenuButton'
          scrapState.waitToOpenCollectionsMenu = true
          collectionKey = $collection.data('collectionkey')
          console.log 'switch to colleciton', $(@).attr 'class'
          containerView.switchToCollection collectionKey
          collectionsMenuView.close()
          scrapState.waitToOpenCollectionsMenu = false
        event.stopPropagation()
        event.preventDefault()
      $collection.css
        width: $(@).width()
        
      
      $collection.find('.contents > a').mouseenter ->
        collectionView.mouseenter $collection
        # If that collection is open and the menu is not open
        if $collection.hasClass('openMenuButton')
          unless scrapState.collectionsMenuIsOpen
            collectionView.showSettings $collection
            
      $collection.find('.contents > a').mouseleave ->
        collectionView.mouseleave $collection
      
      $collection.find('.contents').mouseleave ->
        # If that collection is open and the menu is not open
        if $collection.hasClass('openMenuButton')
          unless scrapState.collectionsMenuIsOpen
            collectionView.hideSettings $collection

  updateHeight: ($collection) ->
    $collection.data 'nativeHeight', Math.max($collection.find('.contents > a').height(), $collection.find('.contents > input').height())
      