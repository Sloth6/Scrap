draggableOptions = (socket) ->
  start: (event, ui) ->
    elem = $(this)
    screenScale = $('.content').css 'scale'
    $(window).off 'mousemove'
    click.x = event.clientX
    click.y = event.clientY
    
    $(".delete.trash").addClass("visible");

    for e in [elem].concat(getComments elem)
      e.data 'startPosition', {
        left: parseFloat(e.css('left')) * screenScale
        top: parseFloat(e.css('top')) * screenScale
      }

  drag: (event, ui) ->
    elem = $(this)
    screenScale = $('.content').css('scale')
    diffX = event.clientX - click.x
    diffY = event.clientY - click.y

    for e in [elem].concat(getComments elem)
      start = e.data 'startPosition'
      e.css('left', (event.clientX - click.x + start.left)/screenScale)
      e.css('top', (event.clientY - click.y + start.top)/screenScale)
      ui.position =
        left: (event.clientX - click.x + startPosition.left) / (screenScale)
        top: (event.clientY - click.y + startPosition.top) / (screenScale)
      
      id = e[0].id
      x = parseInt Math.round(parseInt(e.css('left')) - totalDelta.x)
      y = parseInt Math.round(parseInt(e.css('top')) - totalDelta.y)
      z = parseInt e.zIndex()
      socket.emit 'updateElement', { x, y, z, elementId: id, userId, final: false }

  stop: (event, ui) ->
    elem = $(this)
    $(".delete.trash").removeClass("visible");
    for e in [elem].concat(getComments elem)
      id = elem.attr('id')
      # Make sure to account for screen drag (totalDelta)
      x = parseInt Math.round(parseInt(e.css('left')) - totalDelta.x)
      y = parseInt Math.round(parseInt(e.css('top')) - totalDelta.y)
      z = parseInt e.zIndex()
      
      window.maxX = Math.max x, maxX
      window.minX = Math.min x, minX

      window.maxY = Math.max y, maxY
      window.minY = Math.min y, minY
      userId = window.userId or null
      socket.emit 'updateElement', { x, y, z, elementId: id, userId, final: true }

      makeTextChild e

makeDraggable = (elements, socket) ->
  elements.draggable draggableOptions socket
    # when we mouse over an element we want to bring it to the top temporarily
    # elements
    .on 'mouseover', ->
      elem = $(this)
      for comment in [elem].concat(getComments elem)
        # store its old z-index
        comment.data 'oldZ', comment.css 'z-index'
        comment.css 'z-index', window.maxZ + 1
        comment.addClass 'hover'
        window.maxZ += 1

    # if an item is clicked, we want to make the temporary z-index change
    # permanent.
    .on 'mousedown', ->
      elem = $(this)
      for comment in [elem].concat(getComments elem)
        comment.addClass 'active'
        window.maxZ += 1
        comment.css 'z-index', window.maxZ
        comment.data 'oldZ', comment.css 'z-index'

    .on 'mouseout', ->
      elem = $(this)
      for comment in [elem].concat(getComments elem)
        # reset to old z index, this old zindex may be the current one if
        # the element was clicked
        comment.css 'z-index', $(this).data 'oldZ'
        comment.removeClass 'hover'
        comment.removeClass 'active'

$ ->
  socket = io.connect()
  makeDraggable $('.draggable'), socket
