window.collectionController =
  init: ($collections) ->
    $collections.find('.collectionSettings').hide().css('position', 'absolute')
    styleUtilities.transformOrigin $collections.find('.collectionSettings'), 'center', 'center'
    
    $collections.each ->
      $collection = $(@)
      $collection.zIndex(2)
      $collection.find('.contents a').click (event) ->
        unless $collection.hasClass 'openMenuButton'
          collectionKey = $collection.data('collectionkey')
          containerView.switchToCollection collectionKey
          collectionsMenuView.close()
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
        
      