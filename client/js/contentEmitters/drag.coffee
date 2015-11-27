dragging = null
padding = null
lastDraggingOver = null

collectionOpenByDragTimeout = null
collectionOpenByDragTime = 500

collectionCloseByDragTopTimeout = null
collectionCloseByDragTopTime = 500

scrollInterval = null
draggingOnBorder = false
draggingOnEdgeSpeed = .1
draggingScale = 0.5

dragOptions =  {
  easing: [100, 10],
  duration: 500
}

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

# Take mousemove event while dragging
drag = (event, $dragging) ->
  x = event.clientX
  y = event.clientY
  $collection = $('.collection.open')

  $dragging.velocity {
    translateX: x - $dragging.data('mouseOffsetX')
    translateY: y - $dragging.data('mouseOffsetY')
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

checkForAddToStack = (event, $dragging) ->
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
  
  console.log 'droppedOn', $droppedOn

  if $droppedOn.hasClass 'collection'
    socket.emit "moveToCollection", { elemId: draggedId, collectionKey }
    collectionModel.appendContent $droppedOn, $dragging
    collectionViewController.draw $droppedOn
  else
    $dragging.hide()
    socket.emit 'newStack', { collectionKey: collectionPath[0], draggedId, draggedOverId }
  true

# Clear all timeouts
clearDragTimeouts = () ->
  clearInterval scrollInterval  
  scrollInterval = null
  clearTimeout collectionCloseByDragTopTimeout
  collectionCloseByDragTopTimeout = null
  clearTimeout collectionOpenByDragTimeout
  collectionOpenByDragTimeout = null
  draggingOnBorder = false

stopDragging = (event, $dragging) ->
  if !checkForAddToStack(event, $dragging)
    padding = $('.slidingContainer').find('.padding')
    throw 'did not find padding :(' unless padding.length
    $dragging.insertAfter padding
    padding.remove()

    articles = collectionModel.getContent $('.collection.open')
    articleOrder = JSON.stringify(articles.get().map (elem) -> +elem.id)
    socket.emit 'reorderArticles', { articleOrder, collectionKey: collectionPath[0] }
  
  # Timeout to prevent click event after drag
  setTimeout (() ->
    $dragging.
      removeClass('dragging').
      zIndex $dragging.data('oldZIndex')
    endDragTransform $dragging
    collectionViewController.draw $('.collection.open'), { animate: true }
  ), 20

startDragging = ($dragging, mouseDownEvent) ->
  # console.log 'start dragging', $dragging[0]
  $dragging.data 'mouseOffsetX', (mouseDownEvent.clientX - xTransform($dragging))
  $dragging.data 'mouseOffsetY', (mouseDownEvent.clientY - yTransform($dragging))

  $dragging.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', $dragging.zIndex()).
    zIndex 9999
  
  startDragTransform $dragging
  contentModel.setSize padding, contentModel.getSize($dragging)
  padding.insertAfter $dragging
  # $dragging.insertAfter $('.slidingContainer')
  $('.slidingContainer').append $dragging
  stopPlaying($dragging) if $dragging.hasClass('playable')
  collectionViewController.draw $('.collection.open')
 
makeDraggable = ($content) ->
  $content.find('a,img,iframe').bind 'dragstart', () -> false
  
  $content.on 'mousedown', (mouseDownEvent) ->
    # console.log 'mouseDownEvent', $(@)
    return unless mouseDownEvent.which is 1 # only work for left click
    return if $(@).hasClass 'open'
    return unless collectionModel.getParent($content).hasClass 'open'
    mousedownArticle = $content
    draggingArticle  = null
    
    $(window).mousemove (event) ->
      if draggingArticle == null
        draggingArticle = mousedownArticle
        startDragging draggingArticle, mouseDownEvent
      drag event, draggingArticle
    
    $(window).mouseup (event) ->
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      if draggingArticle?
        stopDragging(event, draggingArticle)


startDragTransform = (e) ->
  e.find('.transform').velocity({
    # 'scale': draggingScale,
    'rotateZ': (Math.random() * 8) - 4
  }, dragOptions)

endDragTransform = (e) ->
  e.find('.transform').velocity({
    # 'scale': 1,
    'rotateZ': 0
  }, dragOptions)

$ ->
  window.padding = $('<article>').addClass('slider sliding padding')
  contentModel.setSize padding, 200
