dragging = null
padding = null
lastDraggingOver = null

draggingOnEdgeSpeed = .1
draggingScale = 0.5

dragOptions =
  easing: [100, 10],
  duration: 500

dragThreshold = 35 #number of pixels in any direction before drag event

startDragTransform = ($dragging) ->
  $dragging.velocity({
    'rotateZ': (Math.random() * .5) * 12
  }, dragOptions)

endDragTransform = ($dragging) ->
  $dragging.velocity({
    'rotateZ': 0
  }, dragOptions)

# Take mousemove event while dragging
drag = (event, $dragging) ->
  x = event.clientX
  y = event.clientY
  scaleThreshhold = $(window).height() / 2
  scale = if y > scaleThreshhold then Math.max(.125, 1 - ((y - scaleThreshhold) / scaleThreshhold)) else 1
  $collection = $('.collection.open')
  
  w = 200# contentModel.getSize($dragging)
  h = 200# Math.max($dragging.find('.content').height(), 200)
  
  offsetPercentX = ($dragging.data('mouseOffsetX') - (w / 2)) / (w/2)
  offsetPercentY = ($dragging.data('mouseOffsetY') - (h / 2)) / (h/2)
  
  scaleOffsetX = (w/2)*(1-scale)*offsetPercentX
  scaleOffsetY = (h/2)*(1-scale)*offsetPercentY

  fudgeY = -.1
  fudgeX = 0
  if $dragging.data('contenttype') == 'stack'
    fudgeX = .1
    fudgeY = -.05

  offsetX = - $dragging.data('mouseOffsetX')
  offsetY = - $dragging.data('mouseOffsetY')

  $dragging.velocity {
    translateX: x - $dragging.data('mouseOffsetX')
    translateY: y - $dragging.data('mouseOffsetY')
    scale: scale
  }, { duration: 1 }
  
  # The content we are moused over
  $content = collectionModel.getContentAt $collection, x
  # When dragging is the only content
  return if $content.length == 0    
  return if $content.is padding

  # Are we over the left, center or right of content
  LCR = leftCenterRight $content, x

  # Prevent spamming the same 
  return if lastDraggingOver is ($content.attr('id') + LCR)

  switch LCR
    when 'left'  then padding.insertBefore $content
    when 'right' then padding.insertAfter $content

  if LCR isnt 'center'
    collectionViewController.draw $collection, { animate: true }
  
  lastDraggingOver = $content.attr('id') + LCR

# utility function
leftCenterRight = ($content, x) ->
  center = .30
  left  = xTransform $content
  size  = contentModel.getSize $content
  right = left + size
  
  if x > right - size*center
    'right'
  else if x < left + size*center
    'left'
  else
    'center'

moveToChild = (event, $dragging) ->
  $(window).off 'mousemove'
  $(window).off 'mouseup'
  
  $collection = $('.collection.open')
  $droppedOn = collectionModel.getContentAt $collection, event.clientX
  return false unless $droppedOn.length
  return false if $droppedOn.is padding
  return false if $dragging.hasClass 'collection'
  return false unless leftCenterRight($droppedOn, event.clientX) is 'center'
  return false if event.clientY < marginTop
  return false if $dragging.is $droppedOn

  collectionKey = collectionModel.getState($droppedOn).collectionKey
  draggedId     = parseInt($dragging.attr('id'))
  draggedOverId = parseInt($droppedOn.attr('id'))
  padding.remove()

  if $droppedOn.hasClass 'collection'
    socket.emit "moveToCollection", { elemId: draggedId, collectionKey }
    collectionModel.appendContent $droppedOn, $dragging
    collectionViewController.draw $droppedOn
  else
    $dragging.hide()
    socket.emit 'newStack', { collectionKey: collectionPath[0], draggedId, draggedOverId }
  true

moveToParent = (event, $dragging) ->
  $collection       = contentModel.getCollection $dragging
  $collectionParent = contentModel.getCollection $collection

  return false if $dragging.hasClass 'collection'
  return false if $collection.data('collectiontype') is 'pack'

  if yTransform($dragging) < -100
    $dragging.insertAfter $collection

    padding.remove()
    history.back()

    data =
      elemId: $dragging.attr('id')
      collectionKey: collectionModel.getState($collectionParent).collectionKey
    socket.emit 'moveToCollection', data
    return true

  false

stopDragging = (mouseUpEvent, $dragging) ->
  return if moveToChild  mouseUpEvent, $dragging
  return if moveToParent mouseUpEvent, $dragging
  
  # Search to insure it is in the Dom.
  padding = $('.slidingContainer').find('.padding')
  throw 'did not find padding' unless padding.length
  $dragging.insertAfter padding
  padding.remove()

  $collection = $('.collection.open')
  collectionOrder = collectionModel.getContentOrder $collection

  socket.emit 'reorderArticles', {
    articleOrder: collectionOrder
    collectionKey: collectionPath[0]
  }

  # Timeout to prevent click event after drag
  setTimeout (() ->
    $dragging.
      removeClass('dragging').
      zIndex $dragging.data('oldZIndex')
    endDragTransform $dragging
    unless $dragging.data 'deleting'
      collectionViewController.draw $('.collection.open'), { animate: true }
  ), 20
  
  footerController.hide()

startDragging = ($dragging, mouseDownEvent) ->
  $dragging.data 'mouseOffsetX', (mouseDownEvent.clientX - xTransform($dragging))
  $dragging.data 'mouseOffsetY', (mouseDownEvent.clientY - yTransform($dragging))
  $collection =  $('.collection.open')

  $dragging.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', $dragging.zIndex()).
    zIndex 9999 

  if $dragging.hasClass 'collection'    
    if $dragging.hasClass 'pack'
      $dragging.data 'previewState', 'none'
      
    else
      $dragging.data 'previewState', 'compact'
    
    collectionViewController.draw $dragging, { animate:true }
    collectionViewController.draw $collection, { animate:true }
 
  startDragTransform $dragging
  
  padding.insertAfter $dragging
  contentModel.setSize padding, contentModel.getSize($dragging)
  padding.data 'margin', articleMargin
  
  $('.slidingContainer').append $dragging
  stopPlaying($dragging) if $dragging.hasClass('playable')
  collectionViewController.draw $collection
  footerController.show $dragging

window.makeDraggable = ($content) ->
  $content.find('a,img,iframe').bind 'dragstart', () -> false
  
  $content.on 'mousedown', (mouseDownEvent) ->
    return unless mouseDownEvent.which is 1 # only work for left click
    return if $(@).hasClass 'open'
    return if $(@).hasClass 'editing'
    return unless collectionModel.getParent($content).hasClass 'open'
    $content.data 'originalCollection', contentModel.getCollection $content
    
    startX = mouseDownEvent.clientX
    startY = mouseDownEvent.clientY

    mousedownArticle = $content
    draggingArticle  = null
        
    $(window).mousemove (event) ->
      if draggingArticle == null
        dX = Math.abs(startX - event.clientX)
        dY = Math.abs(startY - event.clientY)
        if dX < dragThreshold and dY < dragThreshold
          return
        draggingArticle = mousedownArticle
        startDragging draggingArticle, mouseDownEvent
      drag event, draggingArticle
    
    $(window).mouseup (event) ->
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      if draggingArticle?
        stopDragging(event, draggingArticle)

# scrollWindow = (event) ->
#   border = sliderBorder
#   speed = 0
#   if scrollInterval
#     clearInterval scrollInterval
#     draggingOnBorder = false
#     scrollInterval = null

#   if event.clientX < border
#     speed = - (border - event.clientX) * draggingOnEdgeSpeed
#   else if event.clientX > $(window).width() - border
#     speed = (event.clientX - $(window).width() + border) * draggingOnEdgeSpeed
  
#   if speed 
#     draggingOnBorder = true
#     scrollInterval = setInterval (() ->
#       if $('.velocity-animating').length == 0
#         $(window).scrollLeft($(window).scrollLeft() + speed)
#     ), 5