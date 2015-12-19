drawOpenCollection = ($collection, animate) ->
  # return if drawTimeout?
  # clearTimeout drawTimeout
  # drawTimeout = setTimeout (() -> drawTimeout = null), 100
  $contents  = collectionModel.getContent $collection
  $addForm   = collectionModel.getAddForm $collection
  leftMargin = $(window).width() / 2 - $contents.first().find('.card').width() / 2
  rightMargin = $(window).width() / 2 - $contents.last().find('.card').width() / 2
  sizeTotal  = if $collection.hasClass 'root' then leftMargin else 50
  maxX       = -Infinity
  zIndex     = 0#$contents.length
  
  $contents.add($addForm).each () ->
    $(@).
      data('scrollOffset', sizeTotal).
      css { zIndex: zIndex++ }
    
    sizeTotal += contentModel.getSize($(@)) + $(@).data('margin')
    if isNaN(sizeTotal)
      console.log contentModel.getSize($(@)), $(@).data('margin')
      throw 'shit'
    contentViewController.draw $(@), { animate }

  sizeTotal += rightMargin
  
  contentModel.setSize $collection, sizeTotal
  sizeTotal

    # if $(@).hasClass('cover') and $(@).hasClass('open')
    #   $(@).css { zIndex: ($contents.length*3) }
    # # If at root level and elem is add article form, to prevent form from being on top at root level
    # else if $(@).hasClass('addArticleForm') and not $('.root.open').length # (puts add article card at back on root level
    #   $(@).css { zIndex: ($contents.length*3) - 1 }
    # else
    
drawClosedStack = ($collection, spacing = 15) ->
  $cover = collectionModel.getCover($collection)
  $content = collectionModel.getContent $collection
  
  # With a new stack, the dragged over element hides while waiting for a 
  # server resposse
  $content.show()

  collectionModel.getAddForm($collection).hide()
  $content.find('.articleControls').hide()
  $cover.zIndex 0

  translateX = 0
  translateY = 0
  zIndex     = 0#s$content.length
  sizeTotal  = 0
  rotateZ    = 0
  $content.each () ->
    $(@).velocity({ translateX, translateY, rotateZ })
    $(@).css { zIndex: zIndex++ }
    sizeTotal = Math.max(sizeTotal, translateX + $(@).width())
    translateX += spacing

  $cover.find(".card").width sizeTotal
  contentModel.setSize $collection, sizeTotal
  sizeTotal

window.collectionViewController =

  draw: ($collection, options = {}) ->
    animate = options.animate or false
    
    if $collection.hasClass('open')
      drawOpenCollection $collection, animate

    else if $collection.data('collectiontype') == 'stack'
      drawClosedStack($collection)

  # This function is only called from collectionViewController.open
  pushOffScreen: ($collection, $openingCollection) ->
    # Some article move to one side of the view and some move to the other
    # this depends on which side of the opening article they are.
    $openingCover = collectionModel.getCover $openingCollection
    $addForm = collectionModel.getAddForm $collection
    partition = collectionModel.getContentPartitioned $collection, $openingCollection
    { $contentsBefore, $contentsAfter } = partition

    # Animate content offscreen in either direction, hide when done
    $contentsBefore.add($openingCover).each () ->
      isCover = $(@).hasClass 'cover'
      currentX = parseFloat $.Velocity.hook $(@), 'translateX'
      width = contentModel.getSize($(@))
      offLeftEdgeX = -width * 2 - articleMargin * 2
      $(@).velocity
        properties:
          translateZ: [ 0, 0 ]
          translateX: if isCover then offLeftEdgeX else offLeftEdgeX - Math.abs(currentX * 2)
          translateY: 0
          rotateZ:    if isCover then 0 else (Math.random() - .5) * 45
        options: { complete: () -> $(@).hide() }
        $contentsBefore.add($openingCover).each () ->
          if $(@).hasClass 'pack'
            $collectionTransform  = collectionModel.getTransform $(@)
            $collectionTransform.velocity
              scale: 1
      
    $contentsAfter.add($addForm).each () ->
      currentX = parseFloat $.Velocity.hook $(@), 'translateX'
#       translateX = $(window).width() + currentX
      $(@).velocity
        properties:
          translateZ: [ 0, 0 ]
          translateX: $(window).width() + currentX / 2
          translateY: 0
          rotateZ:    (Math.random() - .5) * 45
        options: { complete: () -> $(@).hide() }
      $contentsAfter.each () ->
        if $(@).hasClass 'pack'
          $collectionTransform  = collectionModel.getTransform $(@)
          $collectionTransform.velocity
            scale: 1
    # Mark collection so no longer being open 
    $collection.removeClass('open').addClass 'closed'

  open: ($collection, options = {}) ->
    throw 'no collection passed' unless $collection.length

    $cover                = collectionModel.getCover $collection
    $parentCollection     = collectionModel.getParent $collection
    $collectionContent    = collectionModel.getContent $collection
    $collectionAddForm    = collectionModel.getAddForm $collection
    $collectionTransform  = collectionModel.getTransform $collection
    
    # The root collection has nothing to push off. 
    if $parentCollection
      collectionViewController.pushOffScreen $parentCollection, $collection      
#       if $parentCollection.hasClass 'root'
#         $parentCollection.velocity
#           properties:
#             scale: [1, .5]
#           options:
#             duration: openCollectionDuration
#             easing: openCollectionCurve

    # Make sure cover is above its children during transition
    $cover.css 'z-index': 999
    
    # Animate in content, content appears from behind its cover
    $collectionAddForm.show()
    $collectionContent.find('.articleControls').show()
    $collectionContent.css {'overflow': 'visible' }

    if $collection.data('collectiontype') == 'pack'
      # Container around articles
#       $collection.children('.contentContainer').velocity
#         properties:
#           translateZ: 0
#           opacity: [1, 0]
#         options:
#           duration: openCollectionDuration/2
#           easing: openCollectionCurve
      # Each article
      $collectionContent.add($collectionAddForm).each () ->
        $(@).velocity
          properties:
            translateZ: 0
        $(@).find('.card').each () ->
          $(@).velocity
            properties:
              translateZ: 0
              translateY: [0, $cover.height() - $(@).height() / 2]
              rotateZ: [0, (Math.random() - .5) * 45]
#               scale: [1, .75]
            options:
              complete: () ->
                $(@).css {
                  '-webkit-transform' : ''
                  '-moz-transform' : ''
                  '-ms-transform' : ''
                  'transform' : ''
                }
      $collection.velocity
        properties:
          translateZ: 0
          translateY: 0
          rotateZ: 0
      $collectionTransform.velocity
        properties:
          scale: 1
        options:
          duration: openCollectionDuration
          easing: openCollectionCurve
    else # if stack
      $collection.velocity
        properties:
          rotateZ: 0
#       $cover.hide()
      # Show the add article Form.
      $collectionAddForm.show()
      $collectionContent.show()

    # When opening a collection, it no longer slides but is fixed to start
    $collection.velocity { translateX: 0 }
    $collection.velocity { translateX: 0 }
    $collection.velocity { translateX: 0 }

    # Mark collection as open. 
    $collection.
      addClass('open').
      removeClass 'closed'
    
    collectionViewController.draw $collection, {animate: true}

  close: ($collection, options = {}) ->
    return if $collection.hasClass 'root'

    $collectionCover   = collectionModel.getCover   $collection
    $collectionState   = collectionModel.getState   $collection
    $collectionContent = collectionModel.getContent $collection
    $collectionAddForm = collectionModel.getAddForm $collection
    $collectionTransform = collectionModel.getTransform $collection

    $parentCollection         = collectionModel.getParent  $collection
    $parentCollectionCover    = collectionModel.getCover   $parentCollection
    $parentCollectionState    = collectionModel.getState   $parentCollection
    $parentCollectionContent  = collectionModel.getContent $parentCollection
    $parentCollectionAddForm  = collectionModel.getAddForm $parentCollection

    $collection.
      addClass('closed').
      removeClass('open')
      
    $collectionCover.removeClass('onEdge open')

    # the cover should have a transateX 0 relative to its collection
    $collectionCover.show().velocity { translateX: 0 }
    $collectionCover.css 'z-index': 2
    $parentCollection.addClass('open').removeClass 'closed'
    $parentCollectionContent.show()
    $parentCollectionAddForm.show()
    
    if $collection.hasClass 'root'
      $collection.velocity
        scale: [1, 2]

    if $collection.data('collectiontype') == 'pack'
      # The size of the collection will be reset to just the cover
      contentModel.setSize $collection, null
      $collectionCover.css 'zIndex', 99999
#       $collection.children('.contentContainer').velocity
#         properties:
#           translateZ: 0
#           opacity: [0, 1]
#         options:
#           duration: openCollectionDuration / 2
      $collectionAddForm.velocity
        properties:
          opacity: [0, 1]
          rotateZ: $collectionAddForm.data('jumble').rotateZ
          translateX: 0
          translateY: 0
        options: { complete: () -> $(@).hide() }
      if $collectionContent?
        $collectionContent.each () ->
          $(@).velocity
            properties:
              translateX: $collectionCover.width()  - $(@).width()  / 2
              translateY: $collectionCover.height() - $(@).height() / 2
            options: { complete: () -> $(@).remove() }
          $(@).find('.card').each () ->
            $(@).velocity
              properties:
                rotateZ: (Math.random() - .5) * 45
#                 scale: [.75, 1]
      $parentCollectionContent.add($parentCollectionAddForm).each () ->
        if $(@).hasClass 'pack'
          $collectionTransform = collectionModel.getTransform $(@)
          $collectionTransform.velocity
            properties: 
              scale: .5
      $collectionTransform.velocity
        properties:
          scale: .5
    else # if stack
      $collectionCover.show()
      collectionViewController.draw $collection

  preview: ($collection) ->
    $collectionContent = collectionModel.getContent $collection
    drawClosedStack($collection, 50)
    
