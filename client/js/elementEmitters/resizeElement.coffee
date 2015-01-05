resize = (socket) ->
  (event) ->
    $(this).off 'mouseup'
    event.stopPropagation()
    element = $(this).parent().parent()
    clickX = event.clientX
    clickY = event.clientY
    element.addClass 'resizing'
    screenScale = $('.content').css('scale')

    $(window).on 'mouseup', (event) ->
      socket.emit 'updateElement', { elementId: element.attr('id'), scale: elementScale element }
      element.removeClass 'resizing'

    $(window).on 'mousemove', (event) ->
      event.preventDefault()
      oldElementScale = elementScale element

      deltaX = (event.clientX - clickX) / screenScale
      deltaY = (event.clientY - clickY) / screenScale

      delta = Math.sqrt(deltaX*deltaX + deltaY*deltaY)

      clickX = event.clientX
      clickY = event.clientY

      newScale = delta / Math.sqrt(element.width()*element.width() + element.height() * element.height())
      newScale *= -1 if deltaX < 0 || deltaY < 0

      element.css("scale": Math.max(+oldElementScale + newScale, 0.5))

$ ->

  socket = io.connect()

  $('.ui-resizable-handle').on 'mousedown', resize socket






