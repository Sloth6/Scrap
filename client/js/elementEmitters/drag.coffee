dragging = null
offsetX = 0
offsetY = 0
padding = null
lastn = null
# ging, 10

drag = (event, draggingElement) ->
  # console.log 'dragging'
  x = event.screenX - offsetX
  y = event.screenY - offsetY
  draggingElement.css { x, y }
  clearTimeout lastn if lastn?
  lastn = setTimeout (() ->
    afterMouse = collectionElemAfterMouse(event)
    if afterMouse
      padding.insertBefore collectionElemAfterMouse(event)
    else
      $('.slidingContainer').append padding
    collectionRealign.call $('.slidingContainer'), false
    lastn = null
  ), 10



stopDragging = (elem) ->
  console.log 'stopDragging', elem
  elem.removeClass 'dragging'
  elem.addClass 'sliding'
  elem.css 'zIndex', elem.data('oldZIndex')
  elem.insertAfter padding
  padding.remove()
  collectionRealign.call $('.slidingContainer'), true

startDragging = (elem) ->
  console.log 'startDragging', elem
  elem.addClass 'dragging'
  elem.removeClass 'sliding'
  elem.data 'oldZIndex', elem.zIndex()
  elem.zIndex 9999
  padding.width elem.width()


makeDraggable = (elements) ->
  elements.mousedown (event) ->
    mousedownElement = $(@)
    draggingElement  = null
    windowWidth = $(window).width()
    border = sliderBorder()
    offsetX = event.screenX - parseInt(mousedownElement.css('x'))
    offsetY = event.screenY - parseInt(mousedownElement.css('y'))
    scrollInterval = null

    $(window).mousemove (event) ->
      if draggingElement == null
        draggingElement = mousedownElement
        startDragging draggingElement
        $(window).mouseup () ->
          $(window).off 'mousemove'
          $(window).off 'mouseup'
          setTimeout (() -> stopDragging(draggingElement)), 10      
      
      drag event, draggingElement

      if event.screenX < border and scrollInterval == null
        console.log 'starting setInterval'
        # padding.remove()
        scrollInterval = setInterval (() -> 
          $(window).scrollLeft($(window).scrollLeft() - 15)
        ), 5
      else if event.screenX > (windowWidth - border) and scrollInterval == null
        console.log 'starting setInterval'
        # padding.remove()
        scrollInterval = setInterval (() -> 
          $(window).scrollLeft($(window).scrollLeft() + 15)
        ), 5
      else if scrollInterval
        console.log 'ending setInterval'
        clearInterval scrollInterval
        scrollInterval = null
        
    

$ ->
  window.padding = $('<div>').addClass('slider sliding padding').css 'width', 200
