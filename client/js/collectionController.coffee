window.collectionController =
  init: ($collections) ->
    draggableOptions =
      helper: "clone"
      revert: "true"
      start: (event, ui) ->
        collectionsMenuView.close()
        collectionView.shrinkOnDragOffMenu $(ui.helper)
      stop: (event, ui) ->
        $(ui.helper).off 'hover'
    $collections.each ->
      $collection = $(@)
      $collection.zIndex(2).
        draggable(draggableOptions).
        find('a').click (event) ->
          event.stopPropagation()
          event.preventDefault()
          collectionKey = $collection.data('collectionkey')
          containerView.switchToCollection collectionKey
          collectionsMenuView.close()

      $collection.css
        width: $(@).width()
    parallaxHover $collections.find('a')

