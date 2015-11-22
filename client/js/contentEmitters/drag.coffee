dragging = null
padding = null
lastDraggingOver = [null]

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

  $dragging.velocity {
    translateX: x - $dragging.data('mouseOffsetX')
    translateY: y - $dragging.data('mouseOffsetY') - marginTop
  }, { duration: 1 }
  
  $collection   = $('.collection.open')
  $contentAfter = collectionModel.getContentAfter($collection, x)

  return if $contentAfter[0] == lastDraggingOver[0]
  return if $contentAfter[0] == padding[0]

  if $contentAfter.length
    padding.insertBefore $contentAfter
  else
    collectionModel.appendContent $('.collection.open'), padding
  
  collectionViewController.draw $('.collection.open'), { animate: true }
  lastDraggingOver = $contentAfter

leftCenterRight = (x, $content) ->
  center = .50
  left  = xTransform $content
  size  = contentModel.getSize $content
  right = left + size
  
  if x > right - size/4
    'right'
  else if x < left + size/4
    'left'
  else
    'center'

checkForAddToStack = (event, $dragging) ->
  $(window).off 'mousemove'
  $(window).off 'mouseup'
  x = event.clientX
  droppedOn = collectionModel.getContentAfter $('.collection.open'), x
  return false if droppedOn[0] == padding[0]
  return false unless droppedOn[0]?
  return false if droppedOn.hasClass 'cover'
  return false if $dragging.hasClass('cover')
  return false if $dragging.hasClass('stack')
  return false unless leftCenterRight(x, droppedOn) is 'center'
  return if event.clientY < marginTop
  collectionKey = droppedOn.data 'content'
  
  padding.remove()
  
  draggedId     = parseInt($dragging.attr('id'))
  draggedOverId = parseInt(droppedOn.attr('id'))
  
  if !draggedId or !draggedOverId?
    return false
  else if droppedOn.hasClass('collection')
    console.log 'Emitting move to collection'
    collectionModel.appendContent droppedOn, $dragging
    collectionViewController.draw droppedOn
    collectionKey = collectionModel.getState(droppedOn).collectionKey
    socket.emit "moveToCollection", { elemId: draggedId, collectionKey }
  else
    $dragging.remove()
    socket.emit 'newStack', { collectionKey: collectionPath[0], draggedId, draggedOverId }
  true

checkForOpenByDrag = (x, y, dragging, draggingOver) ->
  return false unless draggingOver.hasClass('stack')
  return false if collectionOpenByDragTimeout
  return false if y > parseInt(draggingOver.css('y'))+ draggingOver.height()
  collectionOpenByDragTimeout = setTimeout (() ->
    padding.remove()
    clearDragTimeouts()
    collectionOpen draggingOver, { dragging: true }
  ), collectionOpenByDragTime
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
  console.log "Stop dragging"
  clearDragTimeouts()  
  
  if !checkForAddToStack(event, $dragging)
    padding = $('.slidingContainer').find('.padding')
    throw 'did not find padding :(' unless padding.length
    $dragging.insertAfter padding
    padding.remove()
  
  articles = collectionModel.getContent $('.collection.open')
  articleOrder = JSON.stringify(articles.get().map (elem) -> +elem.id)
  socket.emit 'reorderArticles', { articleOrder, collectionKey: collectionPath[0] }
  
  # timeout to prevent click event after drag
  setTimeout (() ->
    $dragging.
      removeClass('dragging').
      zIndex $dragging.data('oldZIndex')
    # endDragTransform $dragging.find('.transform')
    collectionViewController.draw $('.collection.open'), {animate: true}
  ), 50

startDragging = ($dragging, mouseDownEvent) ->
  return unless $dragging.hasClass 'draggable'
  
  $dragging.data 'mouseOffsetX', mouseDownEvent.offsetX
  $dragging.data 'mouseOffsetY', mouseDownEvent.offsetY

  $dragging.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', $dragging.zIndex()).
    zIndex 9999
  # startDragTransform $dragging
  contentModel.setSize padding, contentModel.getSize($dragging)
  padding.insertAfter $dragging
  # $dragging.insertAfter $('.slidingContainer')
  $('.slidingContainer').append $dragging
  stopPlaying($dragging) if $dragging.hasClass('playable')
  collectionViewController.draw $('.collection.open')
 
makeDraggable = ($content) ->
  $content.find('a,img,iframe').bind 'dragstart', () -> false
  $content.mousedown (mouseDownEvent) ->
    return unless mouseDownEvent.which is 1 # only work for left click
    return unless $(@).hasClass 'draggable'

    mousedownArticle = $(@)
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
  e.velocity({
    'scale': draggingScale,
    'rotateZ': (Math.random() * 8) - 4
  }, dragOptions)

endDragTransform = (e) ->
  e.velocity({
    'scale': 1,
    'rotateZ': 0
  }, dragOptions)

$ ->
  window.padding = $('<article>').addClass('slider sliding padding')
  padding.css({'background-color': 'red'})
  padding.width 200
  padding.height 200
  contentModel.setSize padding, 200
