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
  afterDrag event, draggingElement

checkForCollectionViaDrop = (event, dragging) ->
  $(window).off 'mousemove'
  $(window).off 'mouseup'
  x = event.clientX
  droppedOn = collectionElemAfter x

  return false if droppedOn[0] == padding[0]
  return false if droppedOn[0] == undefined
  return false if droppedOn.hasClass('cover')
  return false if dragging.hasClass('cover')
  return false unless leftCenterRight(x, droppedOn) is 'center'

  dragging.remove()
  padding.remove()
  collectionRealignDontScale false
  
  draggedId = parseInt(dragging.attr('id'))
  draggedOverId = parseInt(droppedOn.attr('id'))
  console.log "Emitting newCollection."
  socket.emit 'newCollection', { spaceKey: openSpace, draggedId, draggedOverId }
  true

checkForCloseByDrag = (x, y, draggingElement) ->
  return false if $('.open.root').length
  if y < $('.slidingContainer').offset().top
    return true if collectionCloseByDragTopTimeout
    collectionCloseByDragTopTimeout = setTimeout (() ->
      console.log draggingElement.find('.card')
      draggingElement.find('.card').css({
        'scale': 1,
        'rotate': 0
      })
      clearDragTimeouts()
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      collectionClose(draggingElement)
    ), collectionCloseByDragTopTime
    true
  else
    clearTimeout collectionCloseByDragTopTimeout
    collectionCloseByDragTopTimeout = null
    false

checkForOpenByDrag = (x, y, dragging, draggingOver) ->
  return false if !draggingOver.hasClass('cover')
  return false if collectionOpenByDragTimeout
  return false if y > parseInt(draggingOver.css('y'))+ draggingOver.height()
  collectionOpenByDragTimeout = setTimeout (() ->
    padding.remove()
    clearDragTimeouts()
    collectionOpen draggingOver, { dragging: true }
  ), collectionOpenByDragTime
  true

# Check for element reordering or collection creation
afterDrag = (dragEvent, draggingElement) ->
  x = dragEvent.clientX
  y = dragEvent.clientY

  draggingOver = collectionElemAfter x
  checkForCloseByDrag x, y, draggingElement

  return if draggingOver[0] == padding[0]
  
  if draggingOver.is lastDraggingOver
    clearDragTimeouts()

  # if we are dragging at the end
  if draggingOver[0] == undefined
    $('.open.collection .collectionContent').append padding
    collectionRealignDontScale false
  else
    switch leftCenterRight x, draggingOver
      when 'left'
        padding.insertBefore draggingOver
        collectionRealignDontScale false
      when 'right'
        padding.insertAfter draggingOver
        collectionRealignDontScale false
      when 'center'
        console.log 'center'
        checkForOpenByDrag x, y, draggingElement, draggingOver

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

addToCollection = (elem, spaceKey) ->
  elem.addClass(spaceKey)
  console.log 'Emitting move to collection'
  socket.emit "moveToCollection", { elemId: elem.attr('id'), spaceKey }

stopDragging = (event, elem) ->
  console.log "Stop dragging"
  clearDragTimeouts()

  if checkForCollectionViaDrop(event, elem)
    # do nothin
  else 
    if $('.slidingContainer').find('.padding').length # ensure in dom
      elem.insertAfter padding
      padding.remove()
    else 
      console.log 'did not find padding :('
      # shit happens. Put in the closest place
      # elem.insertBefore collectionElemAfter(event.clientX)

    content = collectionChildren().not('.addElementForm')
    elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
    addToCollection(elem, openSpace) if !elem.hasClass(openSpace)
    console.log "Emitting reorderElements"
    socket.emit 'reorderElements', { elementOrder, spaceKey: openSpace }
  
  elem.
    removeClass('dragging').
    addClass('sliding').
    css({
      'z-index': elem.data('oldZIndex')
    }).
    find('.card').
      velocity({
        'scale': 1,
        'rotateZ': 0
      }, {
        easing: [100, 10],
        duration: 500
      })

  collectionRealign true

startDragging = (elem) ->
  elem.
    addClass('dragging').
    removeClass('sliding').
    data('oldZIndex', elem.zIndex()).
    css({
      'z-index': 9999999
    }).
    find('.card').
      velocity({
        'scale': draggingScale,
        'rotateZ': (Math.random() * 8) - (Math.random() * 8)
      }, {
        easing: [100, 10],
        duration: 500
      })
  padding.width(elem.width()*draggingScale).insertAfter elem
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
      if draggingElement != null
        setTimeout (() ->
          stopDragging(event, draggingElement)
        ), 10

$ ->
  window.padding = $('<div>').addClass('slider sliding padding').css 'width', 200 
