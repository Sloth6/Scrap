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

  if draggingOver.hasClass('cover')
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
    # socket.emit 'newCollection', { spaceKey: openSpace, draggedId, draggedOverId }


leftCenterRight = (x, element) ->
  center = .50
  elemLeft = parseInt element.css('x')
  elemWidth = element.width()
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

# "Take mousemove event while dragging"
drag = (event, draggingElement) ->
  x = event.clientX - draggingElement.width()/2
  # y = event.clientY - draggingElement.height()/2
  draggingElement.css { x }
  scrollWindow event
  clearTimeout lastn if lastn?
  afterDrag event, draggingElement
  # if draggingOnBorder is false
  #   lastn = setTimeout (() -> 
  #     afterDrag event, draggingElement
  #     lastn = null
  #   ), 10
  
# Check for element reordering or collection creation
afterDrag = (dragEvent, draggingElement) ->
  x = dragEvent.clientX
  draggingOver = collectionElemAfter x
  return if draggingOver[0] == padding[0]
  
  # if we are dragging at the end
  if draggingOver[0] == undefined
    $('.open.collection .collectionContent').append padding
    collectionRealignDontScale false
  else
    position = leftCenterRight x, draggingOver
    if position is 'left'
      padding.insertBefore draggingOver
      collectionRealignDontScale false
    else if position is 'right'
      padding.insertAfter draggingOver
      collectionRealignDontScale false

  lastDraggingOver = draggingOver

stopDragging = (event, elem) ->
  elem.
    removeClass('dragging').
    addClass('sliding').
    css('zIndex', elem.data('oldZIndex'))
  
  if scrollInterval # sometime scrolling fails to end
    clearInterval scrollInterval
    draggingOnBorder = false
    scrollInterval = null

  position = leftCenterRight event.clientX, lastDraggingOver
  if position is 'center' and !elem.hasClass('cover') and lastDraggingOver[0]?
    mergeIntoCollection elem, lastDraggingOver
  else if $('.slidingContainer').find('.padding').length # ensure in dom
    elem.insertAfter padding
    padding.remove()
    collectionRealign true
    content = collectionChildren().not('.addElementForm')
    elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
    socket.emit 'reorderElements', { elementOrder, spaceKey: openSpace }
  else
    console.log 'did not find padding'


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
    
    $(window).mouseup (event) ->
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      if draggingElement != null
        setTimeout (() ->
          stopDragging(event, draggingElement)
        ), 10

$ ->
  window.padding = $('<div>').addClass('slider sliding padding').css 'width', 200 
