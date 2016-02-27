window.collectionController =
  init: ($collections) ->
    $collections.each ->
      $collection = $(@)
      $collection.zIndex(2).
        find('a').click (event) ->
          unless $collection.hasClass 'openMenuButton'
            collectionKey = $collection.data('collectionkey')
            containerView.switchToCollection collectionKey
            collectionsMenuView.close()
          event.stopPropagation()
          event.preventDefault()
      $collection.css
        width: $(@).width()

