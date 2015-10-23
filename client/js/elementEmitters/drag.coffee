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


leftCenterRight = (x, element) ->
  center = .50
  elemLeft = parseInt element.css('x')
  elemWidth = sliderWidth element
  elemRight = elemLeft + elemWidth
  
  if x > elemRight - elemWidth/4
    'right'
  else if x < elemLeft + elemWidth/4
    'left'
  else
    'center'

scrollWindow = (event) ->
  border = sliderBorder()
  speed = 0
  if scrollInterval
    clearInterval scrollInterval
    draggingOnBorder = false
    scrollInterval = null

  if event.clientX < border
    speed = - (border - event.clientX) * draggingOnEdgeSpeed
  else if event.clientX > $(window).width() - border
    speed = (event.clientX - $(window).width() + border) * draggingOnEdgeSpeed
  
  if speed 
    draggingOnBorder = true
    scrollInterval = setInterval (() ->
      if $('.velocity-animating').length == 0
        $(window).scrollLeft($(window).scrollLeft() + speed)
    ), 5

# Take mousemove event while dragging
drag = (event, draggingElement) ->
  x = event.clientX - draggingElement.width()/2
  y = event.clientY - draggingElement.height()/2
  draggingElement.css { x, y }
  scrollWindow event
  dragTimeout event, draggingElement

checkForAddToStack = (event, dragging) ->
  $(window).off 'mousemove'
  $(window).off 'mouseup'
  x = event.clientX
  droppedOn = collectionElemAfter x
  return false if droppedOn[0] == padding[0]
  return false unless droppedOn[0]?
  return false if droppedOn.hasClass 'cover'
  return false if dragging.hasClass('cover')
  return false if dragging.hasClass('stack')
  return false unless leftCenterRight(x, droppedOn) is 'center'
  return if event.clientY < marginTop
  spaceKey = droppedOn.data 'content'
  
  padding.remove()
  
  draggedId = parseInt(dragging.attr('id'))
  draggedOverId = parseInt(droppedOn.attr('id'))
  
  if !draggedId or !draggedOverId?
    return false
  else if droppedOn.hasClass('stack')
    console.log 'Emitting move to collection'
    stackAdd droppedOn, dragging
    socket.emit "moveToCollection", { elemId: draggedId, spaceKey }
  else
    dragging.remove()
    socket.emit 'newCollection', { spaceKey: spacePath[0], draggedId, draggedOverId }
  true

checkForCloseByDrag = (x, y, draggingElement) ->
  return false unless $('.open.stack').length
  if y < marginTop
    return false if collectionCloseByDragTopTimeout
    console.log 'setting close setTimeout'
    collectionCloseByDragTopTimeout = setTimeout (() ->
      console.log 'collectionCloseByDragTopTimeout'
      clearDragTimeouts()
      elemId = draggingElement.attr 'id'
      spaceKey = spacePath[1]
      socket.emit 'moveToCollection', { elemId, spaceKey }
      # $(window).off 'mousemove'
      # $(window).off 'mouseup'
      history.back()
    ), collectionCloseByDragTopTime
    true
  else
    console.log 'clearTimeout'
    clearTimeout collectionCloseByDragTopTimeout
    collectionCloseByDragTopTimeout = null
    false

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

# Check for element reordering or collection creation
dragTimeout = (dragEvent, draggingElement) ->
  x = dragEvent.clientX
  y = dragEvent.clientY

  draggingOver = collectionElemAfter x
  checkForCloseByDrag x, y, draggingElement

  return if draggingOver[0] == padding[0]
  
  if draggingOver.is lastDraggingOver
    clearDragTimeouts()

  # if we are dragging at the end
  if draggingOver[0] == undefined or draggingOver.hasClass('.addElementForm')
    if $('.addElementForm').prev()[0] isnt padding[0]
      padding.insertBefore $('.addElementForm')
      collectionRealignDontScale false
  else
    switch leftCenterRight x, draggingOver
      when 'left'
        padding.insertBefore draggingOver
        collectionRealignDontScale false

      when 'right'
        padding.insertAfter draggingOver
        collectionRealignDontScale false

      # when 'center'
      #   checkForOpenByDrag x, y, draggingElement, draggingOver

  lastDraggingOver = draggingOver

# Clear all timeouts
clearDragTimeouts = () ->
  clearInterval scrollInterval  
  scrollInterval = null
  clearTimeout collectionCloseByDragTopTimeout
  collectionCloseByDragTopTimeout = null
  clearTimeout collectionOpenByDragTimeout
  collectionOpenByDragTimeout = null
  draggingOnBorder = false

stopDragging = (event, elem) ->
  console.log "Stop dragging"
  clearDragTimeouts()
  
  if checkForAddToStack(event, elem)
    console.log 'checkForAddToStack'
  else 
    if $('.slidingContainer').find('.padding').length # ensure in dom
      elem.insertAfter padding
      padding.remove()
    else 
      console.log 'did not find padding :('
    content = collectionChildren().not('.addElementForm')
    elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
    console.log "Emitting reorderElements"
    socket.emit 'reorderElements', { elementOrder, spaceKey: spacePath[0] }
  
  elem.
    removeClass('dragging').
    addClass('sliding').
    css({
      'z-index': elem.data('oldZIndex')
    })

  endDragTransform elem.find('.transform')
  collectionRealignDontScale()

startDragging = (elem) ->
  return unless elem.hasClass 'draggable'

  elem.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', elem.zIndex()).
    insertAfter('.slidingContainer').
    zIndex 9999

  if elem.hasClass('stack')
    startDragTransform elem.children('.transform').first()
  else
    startDragTransform elem.find('.transform')
  padding.data('width', sliderWidth(elem)*draggingScale).insertAfter elem
  stopPlaying(elem) if elem.hasClass('playable')
 
makeDraggable = (elements) ->
  elements.find('a,img,iframe').bind 'dragstart', () -> false

  elements.mousedown (event) ->
    return unless event.which is 1 # only work for left click
    return unless $(@).hasClass 'draggable'

    mousedownElement = $(@)
    draggingElement  = null
    
    $(window).mousemove (event) ->
      if draggingElement == null
        draggingElement = mousedownElement
        startDragging draggingElement
      drag event, draggingElement
    
    $(window).mouseup (event) ->
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      if draggingElement?
        stopDragging(event, draggingElement)

dragOptions =  {
  easing: [100, 10],
  duration: 500
}

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
  window.padding = $('<div>').addClass('slider sliding padding').data 'width', 200
