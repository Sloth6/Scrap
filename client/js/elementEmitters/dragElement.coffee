draggableOptions = (socket) ->
  start: (event, ui) ->
    elem = $(this)
    screenScale = $('.content').css('scale')

    # $('.delete').addClass('visible')

    $(window).off 'mousemove'
    click.x = event.clientX
    click.y = event.clientY

    window.maxZ += 1
    z = window.maxZ
    $(this).zIndex z

    startPosition.left = ui.position.left
    startPosition.top = ui.position.top 

    # getIdsInCluster( this.id ).forEach (id)->
    if elem.hasClass('cluster')
      elem.data('elems').forEach (id) ->
        e = $('#'+id)
        # console.log e
        e.data 'startPosition', {
          left: parseFloat(e.css('left')) * screenScale
          top: parseFloat(e.css('top')) * screenScale
        }
    else
      elem.data 'startPosition', {
        left: parseFloat(elem.css('left')) * screenScale
        top: parseFloat(elem.css('top')) * screenScale
      }

  drag: (event, ui) ->
    elem = $(this)
    # console.log this
    screenScale = $('.content').css('scale')
    diffX = event.clientX - click.x
    diffY = event.clientY - click.y

    # getIdsInCluster( this.id ).forEach (id)->
    if elem.hasClass('cluster')
      elem.data('elems').forEach (id) ->
        e = $('#'+id)
        start = e.data 'startPosition'
        # console.log start
        e.css('left', (event.clientX - click.x + start.left)/screenScale)
        e.css('top', (event.clientY - click.y + start.top)/screenScale)
        # ui.position =
        #   left: (event.clientX - click.x + startPosition.left) / (screenScale)
        #   top: (event.clientY - click.y + startPosition.top) / (screenScale)
    else
      start = elem.data 'startPosition'
      elem.css('left', (event.clientX - click.x + start.left)/screenScale)
      elem.css('top', (event.clientY - click.y + start.top)/screenScale)

    ui.position =
      left: (event.clientX - click.x + startPosition.left) / (screenScale)
      top: (event.clientY - click.y + startPosition.top) / (screenScale)

  stop: (event, ui) ->
    elem = $(this)
    $('.delete').removeClass 'visible'

    # getIdsInCluster( this.id ).forEach (id) ->
    id = this.id
    # Make sure to account for screen drag (totalDelta)
    x = Math.round(parseInt(elem.css('left')) - totalDelta.x)
    y = Math.round(parseInt(elem.css('top')) - totalDelta.y)
    z = elem.zIndex()
    # elementId = id
    
    window.maxX = Math.max x, maxX
    window.minX = Math.min x, minX

    window.maxY = Math.max y, maxY
    window.minY = Math.min y, minY

    socket.emit('updateElement', { x, y, z, elementId: id })
    cluster()

$ ->
  socket = io.connect()

  $('article').draggable draggableOptions socket
    .on 'mouseover', ->
      $(this).data('oldZ', $(this).css 'z-index')
      $(this).css 'z-index', window.maxZ + 1
    .on 'mouseout', ->
      $(this).css 'z-index', $(this).data 'oldZ'
    .on 'click', ->
      $(window).trigger 'mouseup'
      socket.emit 'updateElement', { z: $(this).css('z-index'), elementId: $(this).attr 'id' }
