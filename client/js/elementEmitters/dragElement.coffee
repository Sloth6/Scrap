draggableOptions = (socket) ->
  start: (event, ui) ->
    screenScale = $('.content').css('scale')
    if not getIdsInCluster( this.id )?
      return
    $('.delete').addClass 'visible'
    $(this).addClass 'dragging'
    $(window).off 'mousemove'
    click.x = event.clientX
    click.y = event.clientY

    window.maxZ += 1
    z = window.maxZ
    $(this).zIndex z

    startPosition.left = ui.position.left
    startPosition.top = ui.position.top 

    getIdsInCluster( this.id ).forEach (id)->
      elem = $('#'+id)
      elem.data 'startPosition', {
        left: parseFloat(elem.css('left')) * screenScale
        top: parseFloat(elem.css('top')) * screenScale
      }

  drag: (event, ui) ->
    screenScale = $('.content').css('scale')
    diffX = event.clientX - click.x
    diffY = event.clientY - click.y
    getIdsInCluster( this.id ).forEach (id)->
      elem = $('#'+id)
      start = elem.data 'startPosition'
      elem.css('left', (event.clientX - click.x + start.left)/screenScale)
      elem.css('top', (event.clientY - click.y + start.top)/screenScale)

    ui.position =
      left: (event.clientX - click.x + startPosition.left) / (screenScale)
      top: (event.clientY - click.y + startPosition.top) / (screenScale)

  stop: (event, ui) ->
    $('.delete').removeClass 'visible'
    $(this).removeClass 'dragging'
    getIdsInCluster( this.id ).forEach (id) ->
      elem = $('#'+id)
      # Make sure to account for screen drag (totalDelta)
      x = Math.round(parseInt(elem.css('left')) - totalDelta.x)
      y = Math.round(parseInt(elem.css('top')) - totalDelta.y)
      z = elem.zIndex()
      elementId = id
      
      window.maxX = Math.max x, maxX
      window.minX = Math.min x, minX

      window.maxY = Math.max y, maxY
      window.minY = Math.min y, minY

      socket.emit('updateElement', { x, y, z, elementId })

$ ->
  socket = io.connect()

  $('article').draggable draggableOptions socket
    .on 'mouseover', ->
      $(this).data('oldZ', $(this).css 'z-index')
      $(this).css 'z-index', window.maxZ + 1
    .on 'mouseout', ->
      $(this).css 'z-index', $(this).data 'oldZ'
    .on 'click', ->
      socket.emit 'updateElement', { z: $(this).css('z-index'), elementId: $(this).attr 'id' }