window.collectionController =
  init: ($collections) ->
    $collections.each ->
      $collection = $(@)
      $collection.zIndex(2)
      $collection.find('a').click (event) ->
        unless $collection.hasClass 'openMenuButton'
          collectionKey = $collection.data('collectionkey')
          containerView.switchToCollection collectionKey
          collectionsMenuView.close()
        event.stopPropagation()
        event.preventDefault()
      $collection.find('a').mouseenter ($collection) -> collectionView.mouseenter $collection
      $collection.find('a').mouseleave ($collection) -> collectionView.mouseenter $collection
      $collection.css
        width: $(@).width()

