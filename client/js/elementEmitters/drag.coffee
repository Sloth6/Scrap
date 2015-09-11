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
  
  draggedId = parseInt(dragging.attr('id'))
  draggedOverId = parseInt(draggingOver.attr('id'))
  $(window).off 'mousemove'
  $(window).off 'mouseup'

  if dragging.hasClass('cover') and !draggingOver.hasClass('cover')
    # cannot merge a collection onto an element
    stopDragging dragging
  
  else if draggingOver.hasClass('cover')
    # add an element to a collection
    console.log 'adding', dragging[0], draggingOver[0]
    dragging.remove()
    padding.remove()
    collectionRealignDontScale false
    spaceKey = draggingOver.data 'spacekey'
    socket.emit 'moveToCollection', { spaceKey, elemId: draggedId }

  else
    # create a new collection
    console.log 'merging', dragging[0], draggingOver[0]
    dragging.remove()
    padding.remove()
    collectionRealignDontScale false
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


"Check for element reordering or collection creation"
afterDrag = (dragEvent, draggingElement) ->
  draggingOver = collectionElemAfterMouse dragEvent
  # console.log 'afterDrag', draggingOver[0]
  return if draggingOver[0] == padding[0]
  
  #"Timeout before calling drop event"
  clearTimeout draggingOverTimeout
  draggingOverTimeout = null

  position = leftCenterRight dragEvent, draggingOver
  if position is 'center'
    draggingOverTimeout = setTimeout (() ->
      if collectionElemAfterMouse(dragEvent)[0] == draggingOver[0]
        mergeIntoCollection draggingElement, draggingOver
    ), dragUntilCollectionTime
  
  else if position is 'left'
    padding.insertBefore draggingOver
    collectionRealignDontScale false
  else if position is 'right'
    padding.insertAfter draggingOver
    collectionRealignDontScale false
  
  lastDraggingOver = draggingOver


# "Take mousemove event while dragging"
drag = (event, draggingElement) ->
  border = sliderBorder()
  x = event.clientX - draggingElement.width()/2
  # y = event.clientX - draggingElement.height()/2
  draggingElement.css { x }

  clearTimeout lastn if lastn?
  if draggingOnBorder is false
    lastn = setTimeout (() -> 
      afterDrag event, draggingElement
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
    collectionRealign true
    content = collectionChildren().not('.addElementForm')
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
