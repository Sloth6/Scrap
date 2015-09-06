dragging = null
padding = null
lastn = null
oldAfterMouse = null

scrollInterval = null
draggingOnBorder = false
draggingOnEdgeSpeed = .1
draggingScale = 0.5

drag = (event, draggingElement) ->
  border = sliderBorder()
  x = event.clientX - draggingElement.width()/2
  y = event.clientY - draggingElement.height()/2
  draggingElement.css { x }
  
  clearTimeout lastn if lastn?
  if draggingOnBorder is false
    lastn = setTimeout (() ->
      # get the element to insert the dragging element in front of
      newAfterMouse = collectionElemAfterMouse event
      # if there is one
      if newAfterMouse
        if (oldAfterMouse == null) or (newAfterMouse[0] != oldAfterMouse[0]) and newAfterMouse[0] != padding[0]
          padding.insertBefore newAfterMouse
          oldAfterMouse = newAfterMouse
          collectionRealignDontScale.call $('.slidingContainer'), false
      else # Is the last element in collection
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
      if $('.velocity-animating').length == 0
        $(window).scrollLeft($(window).scrollLeft() + speed)
    ), 5

stopDragging = (elem) ->
  # console.log 'stopDragging', elem[0]
  elem.
    removeClass('dragging').
    addClass('sliding').
    css('zIndex', elem.data('oldZIndex'))
  
  # sometime scrolling fails to end
  if scrollInterval
    clearInterval scrollInterval
    draggingOnBorder = false
    scrollInterval = null

  # if the padding is actually in the dom
  if $('.slidingContainer').find('.padding').length
    elem.insertAfter(padding)
    padding.remove()
    collectionRealign.call $('.slidingContainer'), true
    content = collectionContent.call $('.slidingContainer')
    elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
    socket.emit 'reorderElements', { elementOrder, spaceKey: openSpace }

startDragging = (elem) ->
  # console.log 'startDragging', elem[0]
  elem.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', elem.zIndex()).
    css { 'scale': draggingScale, 'z-index': 999 }

  padding.width elem.width()/2


makeDraggable = (elements) ->
  # console.log elements.find('a')
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
