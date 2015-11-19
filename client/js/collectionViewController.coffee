drawOpenCollection = ($collection, animate) ->
  return if drawTimeout?
  clearTimeout drawTimeout
  drawTimeout = setTimeout (() -> drawTimeout = null), 100
  $contents  = collectionModel.getContent $collection
  $addForm   = collectionModel.getAddForm $collection
  sizeTotal  = 0
  maxX       = -Infinity
  zIndex     = $contents.length

  $contents.add($addForm).each () ->
    $(@).data 'scrollOffset', sizeTotal
    # if $(@).hasClass('cover') and $(@).hasClass('open')
    #   $(@).css { zIndex: ($contents.length*3) }
    # # If at root level and elem is add element form, to prevent form from being on top at root level
    # else if $(@).hasClass('addElementForm') and not $('.root.open').length # (puts add element card at back on root level
    #   $(@).css { zIndex: ($contents.length*3) - 1 }
    # else
    $(@).css { zIndex: zIndex++ }
    contentViewController.draw $(@), null, { animate }
    sizeTotal += contentModel.getSize($(@)) + margin
  
  sizeTotal

drawClosedStack = ($collection) ->
  console.log 'drawing stack', $collection
  $cover = collectionModel.getCover($collection)
  collectionModel.loadContent $collection, () ->
    $content = collectionModel.getContent $collection
    $content.find('.elementControls').hide()
    collectionModel.getAddForm($collection).hide()

    translateX = 0
    translateY = 0
    zIndex     = $content.length
    $content.each () ->
      $(@).velocity { translateX, translateY }
      $(@).css {zIndex: zIndex++}
      translateX += 50

    # subtract 50 for last addition and add element form
    sizeTotal = contentModel.getSize($content.last()) + translateX - 100
    $cover.find(".card").width sizeTotal
    
    contentModel.setSize $collection, sizeTotal

    collectionViewController.draw $('.collection.open')
    size = contentModel.getSize $('.collection.open')

window.collectionViewController =
  getContentSize: ($collection) ->
    content = collectionViewController.content $collection
    size = 0
    content.each () ->
      size += contentModel.getSize($(@)) + margin
    size

  draw: ($collection, options = {}) ->
    animate = options.animate or false
    
    if $collection.hasClass('open')
      size = drawOpenCollection $collection, animate
      contentModel.setSize $collection, size

    else if $collection.data('contenttype') == 'stack'
      drawClosedStack($collection)

  # This function is only called from collectionViewController.open
  pushOffScreen: ($collection, $openingCollection) ->
    # Some element move to one side of the view and soem move to the other
    # this depends on which side of the opening element they are.
    $openingCover = collectionModel.getCover $openingCollection
    $addForm = collectionModel.getAddForm $collection
    partition = collectionModel.getContentPartitioned $collection, $openingCollection
    { $contentsBefore, $contentsAfter } = partition

    # $contentsBefore.removeClass 'dragging'
    # $contentsAfter.removeClass 'dragging'

    # Animate content offscreen in either direction, hide when done
    $contentsBefore.add($openingCover).velocity
      properties:
        translateZ: [ 0, 0 ]
        translateX: [ (() -> -contentModel.getSize($(@))), xOfSelf ]
        translateY: [yOfSelf, yOfSelf]
      options: { complete: () -> $(@).hide() }

    $contentsAfter.add($addForm).velocity
      properties:
        translateZ: [ 0, 0 ]
        translateX: [ $(window).width(), xOfSelf ]
        translateY: [yOfSelf, yOfSelf]
      options: { complete: () -> $(@).hide() }

    # Mark collection so no longer being open 
    $collection.removeClass('open').addClass 'closed'

  open: ($collection, options = {}) ->
    console.log 'open', $collection.attr('class')
    throw 'no collection passed' unless $collection.length
    throw 'cant open an open collection' if $collection.hasClass 'open'

    $cover             = collectionModel.getCover $collection
    $parentCollection  = collectionModel.getParent $collection
    $collectionContent = collectionModel.getContent $collection
    $collectionAddForm = collectionModel.getAddForm $collection
    # The root collection has nothing to push off. 
    if $parentCollection
      collectionViewController.pushOffScreen $parentCollection, $collection
    
    # Initialize new content to make it interactive
    contentModel.init $collectionContent
    contentModel.init $collectionAddForm

    # Make sure cover is above its children during transition
    $cover.css 'z-index': 999
    # Animate in content, content appears from behind its cover

    $collectionAddForm.show()
    if $collection.data('contenttype') == 'pack'
      $collectionContent.add($collectionAddForm).velocity
        opacity: [1, 0]
        x: [ xTransform($cover), xOfSelf ]
    else
      $cover.hide()
      # Show the add element Form.
      $collectionAddForm.show()
      $collectionContent.show()

    # When opeing a collection, it no longer slides but is fixed to start
    $collection.velocity { translateX: 0 }
    $collection.removeClass 'draggable'

    # Mark collection as open. 
    $collection.addClass('open').removeClass 'closed'

  close: ($collection, options = {}) ->
    console.log 'clossing', $collection.attr('class')
    return if $collection.hasClass 'root'

    $collectionCover   = collectionModel.getCover   $collection
    $collectionState   = collectionModel.getState   $collection
    $collectionContent = collectionModel.getContent $collection
    $collectionAddForm = collectionModel.getAddForm $collection

    $parentCollection         = collectionModel.getParent  $collection
    $parentCollectionCover    = collectionModel.getCover   $parentCollection
    $parentCollectionState    = collectionModel.getState   $parentCollection
    $parentCollectionContent  = collectionModel.getContent $parentCollection
    $parentCollectionAddForm  = collectionModel.getAddForm $parentCollection

    $collection.
      addClass('closed').
      removeClass('open').
      addClass('draggable')

    # the cover should have a transateX 0 relative to its collection
    $collectionCover.show().velocity { translateX: 0 }
    $collectionCover.css 'z-index': 2
    $parentCollection.addClass('open').removeClass 'closed'
    $parentCollectionContent.show()
    $parentCollectionAddForm.show()

    if $collection.data('contenttype') == 'pack'
      # The size of the collection will be reset to just the cover
      contentModel.setSize $collection, null
      $collectionAddForm.velocity
        properties: { opacity: [0, 1] }
        options: { complete: () -> $(@).hide() }
      $collectionContent.velocity
        properties: { opacity: [0, 1] }
        options: { complete: () -> $(@).remove() }
    else
      $collectionCover.show()
      $collectionContent.removeClass 'draggable'
      collectionViewController.draw $collection