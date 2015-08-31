dragging = null
offsetX = 0
offsetY = 0
padding = null
lastn = null

$ ->
  padding = $('<div>').addClass('slider sliding padding').css 'width', 200

mouseup = (event) ->
  $(window).off 'mousemove', mousemove
  $(window).off 'mouseup', mouseup
  setTimeout stopDragging, 10

mousemove = (event) ->
  x = event.screenX - offsetX
  y = event.screenY - offsetY
  dragging.css { x, y }
  clearTimeout lastn if lastn?
  lastn = setTimeout (() ->
    padding.insertBefore collectionElemAfterMouse(event)
    collectionRealign.call $('.slidingContainer'), false
    lastn = null
  ), 15

stopDragging = () ->
  dragging.removeClass 'dragging'
  dragging.addClass 'sliding'
  dragging.css 'zIndex', dragging.data('oldZIndex')
  offsetX = 0
  offsetY = 0
  dragging.insertAfter padding
  padding.remove()
  dragging = null
  collectionRealign.call $('.slidingContainer')
  


startDragging = (event) ->
  dragging = $(@)
  dragging.addClass 'dragging'
  dragging.removeClass 'sliding'

  dragging.data 'oldZIndex', $(@).css('zIndex')
  dragging.zIndex 9999
  padding.width dragging.width()
  offsetX = event.screenX - parseInt(dragging.css('x'))
  offsetY = event.screenY - parseInt(dragging.css('y'))
  $(window).mousemove mousemove
  $(window).mouseup mouseup

makeDraggable = (elements) ->
  console.log elements
  elements.mousedown startDragging
