dragging = null
padding = null
lastn = null
lastDraggingOver = null
draggingOverTimeout = null

dragUntilCollectionTime = 1500
scrollInterval = null
draggingOnBorder = false
draggingOnEdgeSpeed = .1
draggingScale = 0.5

mergeIntoCollection = (dragging, draggingOver) ->
  console.log 'merging', dragging, draggingOver
  draggedId = parseInt(dragging.attr('id'))
  draggedOverId = parseInt(draggingOver.attr('id'))

  dragging.remove()
  $(window).off 'mousemove'
  $(window).off 'mouseup'
  socket.emit 'newCollection', { spaceKey: openSpace, draggedId, draggedOverId }

leftCenterRight = ({ clientX }, element) ->
  center = .50
  elemLeft = parseInt element.css('x')
  elemWidth = element.width()
  elemRight = elemLeft + elemWidth
  
  if clientX > elemRight - elemWidth/4
    'right'
  else if clientX < elemLeft + elemWidth/4
    'left'
  else
    'center'

foo = (dragEvent, draggingElement) ->
  draggingOver = collectionElemAfterMouse dragEvent
  return if draggingOver[0] == padding[0]
  clearTimeout draggingOverTimeout
  draggingOverTimeout = null
  position = leftCenterRight dragEvent, draggingOver
  # if (lastDraggingOver == null) or (draggingOver[0] != lastDraggingOver[0])# and draggingOver[0] != padding[0]
  
  if position is 'center'
    draggingOverTimeout = setTimeout (() ->
      mergeIntoCollection draggingElement, draggingOver
    ), dragUntilCollectionTime
  else if position is 'left'
    padding.insertBefore draggingOver
  else if position is 'right'
    padding.insertAfter draggingOver
  collectionRealignDontScale.call $('.slidingContainer'), false

  lastDraggingOver = draggingOver

drag = (event, draggingElement) ->
  border = sliderBorder()
  x = event.clientX - draggingElement.width()/2
  x = event.clientX - draggingElement.height()/2
  draggingElement.css { x }
  
  clearTimeout lastn if lastn?
  if draggingOnBorder is false
    lastn = setTimeout (() -> 
      foo event, draggingElement
      lastn = null
    ), 10
  
  speed = 0
  if scrollInterval
    clearInterval scrollInterval
    draggingOnBorder = false
    scrollInterval = null

  if event.screenX < border
    speed = - (border - event.screenX) * draggingOnEdgeSpeed
  else if event.screenX > $(window).width() - border
    speed = (event.screenX - $(window).width() + border) * draggingOnEdgeSpeed
  
  if speed 
    draggingOnBorder = true
    scrollInterval = setInterval (() ->
      if $('.velocity-animating').length == 0
        $(window).scrollLeft($(window).scrollLeft() + speed)
    ), 5

stopDragging = (elem) ->
  elem.
    removeClass('dragging').
    addClass('sliding').
    css('zIndex', elem.data('oldZIndex'))
  
  if scrollInterval # sometime scrolling fails to end
    clearInterval scrollInterval
    draggingOnBorder = false
    scrollInterval = null

  if $('.slidingContainer').find('.padding').length # ensure in dom
    elem.insertAfter padding
    padding.remove()
    collectionRealign.call $('.slidingContainer'), true
    content = collectionContent.call $('.slidingContainer')
    elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
    socket.emit 'reorderElements', { elementOrder, spaceKey: openSpace }

startDragging = (elem) ->
  elem.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', elem.zIndex()).
    css { 'scale': draggingScale, 'z-index': 999 }

  padding.width elem.width()/2

makeDraggable = (elements) ->
  elements.find('a,img,iframe').bind 'dragstart', () ->
    console.log $(@)
    return false

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
    
    $(window).mouseup () ->
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      if draggingElement != null
        setTimeout (() -> stopDragging(draggingElement)), 10      

$ ->
  window.padding = $('<div>').addClass('slider sliding padding').css 'width', 200 
