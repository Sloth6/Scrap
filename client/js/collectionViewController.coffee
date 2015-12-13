drawOpenCollection = ($collection, animate) ->
  # return if drawTimeout?
  # clearTimeout drawTimeout
  # drawTimeout = setTimeout (() -> drawTimeout = null), 100
  $contents  = collectionModel.getContent $collection
  $addForm   = collectionModel.getAddForm $collection
  leftMargin = $(window).width()/2 - $contents.first().find('.card').width() / 2
  rightMargin = $(window).width()/2 - $contents.last().find('.card').width() / 2
  sizeTotal  = leftMargin
  maxX       = -Infinity
  zIndex     = $contents.length

  $contents.add($addForm).each () ->
    $(@).
      data('scrollOffset', sizeTotal).
      css { zIndex: zIndex++ }
    contentViewController.draw $(@), null, { animate }
    sizeTotal += contentModel.getSize($(@)) + $(@).data('margin')
  sizeTotal += rightMargin
  
  contentModel.setSize $collection, sizeTotal
  sizeTotal

    # if $(@).hasClass('cover') and $(@).hasClass('open')
    #   $(@).css { zIndex: ($contents.length*3) }
    # # If at root level and elem is add article form, to prevent form from being on top at root level
    # else if $(@).hasClass('addArticleForm') and not $('.root.open').length # (puts add article card at back on root level
    #   $(@).css { zIndex: ($contents.length*3) - 1 }
    # else
    
getWidestArticle = ($content) ->
  widest = 0
  $content.each () ->
    if $(@).width() > widest
      widest = $(@).width()
  widest

drawCollectionPreview = ($collection, animate) ->
  $cover = collectionModel.getCover($collection)
  $content = collectionModel.getContent $collection
  $contentContainer = contentModel.getContentContainer $content
  # With a new stack, the dragged over element hides while waiting for a 
  # server response
  $content.show()
  
  $contentContainer.css 'background', 'red'
  
  collectionModel.getAddForm($collection).hide()
  $cover.zIndex 9999
  
#   $content.each () ->
#     $(@).css 'max-width', $cover.width()

  translateX  = if $collection.data('contenttype') is 'pack' then $cover.width() else 0
  translateY  = 0
  zIndex      = $content.length
  sizeTotal   = 0
  widest      = getWidestArticle($content)
  duration    = if $collection.data('drawInstant') then 1 else openCollectionDuration
  rightAlignOffset = 0
  rightAlignOffsetSizeTotal = 0
  spacing = 0
#   console.log 'widest', widest
  $content.each () ->
    switch $collection.data('previewState')
      when 'compact'
        spacing = 10 #2 * Math.exp(($(@).index() + 1), 2)
        rotateZ = 0 #(Math.random() - .5) * 10
      when 'expanded'
        spacing = 100 #$(@).width() / 2 #10 * Math.exp(($(@).index() + 1), 2)
        rotateZ = 0
      when 'compactReverse'
        spacing = -10
        rotateZ = 0 #(Math.random() - .5) * 10
        rightAlignOffset = -widest + (widest - $(@).width()) + ($content.length * -spacing)
        rightAlignOffsetSizeTotal = -$cover.width()
      when 'none'
        spacing = 0
        rotateZ = 0
        rightAlignOffset = -widest + (widest - $(@).width()) + ($content.length * -spacing)
        rightAlignOffsetSizeTotal = -$cover.width()
#         coverOffset = 0
    $(@).velocity
      properties:
        translateX: translateX + rightAlignOffset
        translateY: translateY
        rotateZ: rotateZ
      options:
        duration: duration
    contentWidth = if $collection.data('contenttype') is 'pack' then 0 else $(@).width()
    sizeTotal += Math.max(sizeTotal, translateX + contentWidth + rightAlignOffsetSizeTotal)
    translateX += spacing
    
#   $cover.find(".card").width sizeTotal
  sizeTotal += if $collection.data('contenttype') is 'pack' then $cover.width() else 0
  contentModel.setSize $collection, sizeTotal
#   console.log sizeTotal
  sizeTotal

window.collectionViewController =

  draw: ($collection, options = {}) ->
#     console.log 'draw!'
    animate = options.animate or false
    
    if $collection.hasClass('open')
      drawOpenCollection $collection, animate

    else if $collection.data('contenttype') == 'stack'
      drawCollectionPreview $collection, animate
      
    else if $collection.data('contenttype') == 'pack'
      drawCollectionPreview $collection, animate

  # This function is only called from collectionViewController.open
  pushOffScreen: ($collection, $openingCollection) ->
    # Some article move to one side of the view and some move to the other
    # this depends on which side of the opening article they are.
    $openingCover = collectionModel.getCover $openingCollection
    $addForm = collectionModel.getAddForm $collection
    partition = collectionModel.getContentPartitioned $collection, $openingCollection
    { $contentsBefore, $contentsAfter } = partition

    # Animate content offscreen in either direction, hide when done
    $contentsBefore.add($openingCover).velocity
      properties:
        translateZ: [ 0, 0 ]
        translateX: [ (() -> -contentModel.getSize($(@))), xOfSelf ]
        translateY: [0, yOfSelf]
        rotateZ:    0
      options: { complete: () -> $(@).hide() }

    $contentsAfter.add($addForm).velocity
      properties:
        translateZ: [ 0, 0 ]
        translateX: [ $(window).width(), xOfSelf ]
        translateY: [0, yOfSelf]
        rotateZ:    0
      options: { complete: () -> $(@).hide() }

    # Mark collection so no longer being open 
    $collection.removeClass('open').addClass 'closed'

  open: ($collection, options = {}) ->
    throw 'no collection passed' unless $collection.length

    $cover             = collectionModel.getCover $collection
    $parentCollection  = collectionModel.getParent $collection
    $collectionContent = collectionModel.getContent $collection
    $collectionAddForm = collectionModel.getAddForm $collection
    
    # The root collection has nothing to push off. 
    if $parentCollection
      collectionViewController.pushOffScreen $parentCollection, $collection

    # Make sure cover is above its children during transition
    $cover.css 'z-index': 999
    
    # Animate in content, content appears from behind its cover
    $collectionAddForm.show()
    $collectionContent.find('.articleControls').show()
    $collectionContent.css {'overflow': 'visible' }
    if $collection.data('contenttype') == 'pack'
      # Container around articles
      $collection.children('.contentContainer').velocity
        properties:
          translateZ: 0
          opacity: [1, 0]
        options:
          duration: openCollectionDuration/2
          easing: openCollectionCurve
      # Each article
      $collectionContent.add($collectionAddForm).each () ->
        $(@).velocity
          properties:
            translateZ: 0
            translateY: 0
        $(@).find('.card').each () ->
          $(@).velocity
            properties:
              translateZ: 0
              rotateZ: [0, (Math.random() - .5) * 90]
              scale: [1, .5]
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
    else
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
    
    collectionViewController.draw $collection #, {animate: true}

  close: ($collection, options = {}) ->
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
      removeClass('open')

    # the cover should have a transateX 0 relative to its collection
    $collectionCover.show().velocity { translateX: 0 }
    $collectionCover.css 'z-index': 2
    $parentCollection.addClass('open').removeClass 'closed'
    $parentCollectionContent.show()
    $parentCollectionAddForm.show()

    if $collection.data('contenttype') == 'pack'
      # The size of the collection will be reset to just the cover
      contentModel.setSize $collection, null
      $collectionCover.css 'zIndex', 99999
      $collection.children('.contentContainer').velocity
        properties:
          translateZ: 0
          opacity: [0, 1]
        options:
          duration: openCollectionDuration / 2
      $collectionAddForm.velocity
        properties:
          opacity: [0, 1]
          rotateZ: $collectionAddForm.data('jumble').rotateZ
          translateX: 0
          translateY: 0
          scale: [.5, 1]
        options: { complete: () -> $(@).hide() }
      if $collectionContent?
        $collectionContent.each () ->
          $(@).velocity
            properties:
              translateX: 0
              translateY: $(@).height() / 4
              rotateZ: (Math.random() - .5) * 90
              scale: [.5, 1]
            options: { complete: () -> $(@).remove() }
              
    else
      $collectionCover.show()
      collectionViewController.draw $collection

  preview: ($collection) ->
    $collectionContent = collectionModel.getContent $collection
    drawCollectionPreview($collection, 50)
    
