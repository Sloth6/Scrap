dragging = null
offsetX = 0
offsetY = 0
padding = null
lastn = null
oldAfterMouse = null

scrollInterval = null
draggingOnBorder = false
draggingOnEdgeSpeed = .1
draggingScale = 0.5

drag = (event, draggingElement) ->
  # console.log 'dragging'
  border = sliderBorder()
  x = event.screenX - offsetX
  y = event.screenY - offsetY
  draggingElement.css { x, y }
  
  clearTimeout lastn if lastn?
  
  if draggingOnBorder is false
    lastn = setTimeout (() ->
      newAfterMouse = collectionElemAfterMouse(event)
      if newAfterMouse
        if (oldAfterMouse == null) or (newAfterMouse[0] != oldAfterMouse[0])
          padding.insertBefore collectionElemAfterMouse(event)
          oldAfterMouse = newAfterMouse
          collectionRealignDontScale.call $('.slidingContainer'), false
      else
        $('.slidingContainer').append padding
        collectionRealignDontScale.call $('.slidingContainer'), false
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
      $(window).scrollLeft($(window).scrollLeft() + speed)
    ), 5

stopDragging = (elem) ->
  console.log 'stopDragging', elem[0]
  elem.
    removeClass('dragging').
    addClass('sliding').
    css('zIndex', elem.data('oldZIndex'))
  
  elem.insertAfter(padding) if padding?

  padding.remove()
  collectionRealign.call $('.slidingContainer'), true
  content = collectionContent.call $('.slidingContainer')
  elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
  socket.emit 'reorderElements', { elementOrder, spaceKey: openSpace }

startDragging = (elem) ->
  console.log 'startDragging', elem[0]
  elem.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', elem.zIndex()).
    css { 'scale': draggingScale, 'z-index': 999 }

  # console.log elem.zIndex()
  # setInterval (() -> console.log elem.zIndex()), 100
  padding.width elem.width()


makeDraggable = (elements) ->
  elements.mousedown (event) ->
    return unless event.which is 1 # only work for left click
    return unless $(@).hasClass 'draggable'

    mousedownElement = $(@)
    draggingElement  = null
    
    offsetX = event.screenX - parseInt(mousedownElement.css('x'))
    offsetY = event.screenY - parseInt(mousedownElement.css('y'))

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
 
