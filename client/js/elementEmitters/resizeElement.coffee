resize = (socket) ->
  (event) ->
    # return if elem.hasClass 'locked'
    $(this).off 'mouseup'
    event.stopPropagation()
    element = $(this).parent()
    clickX = event.clientX
    clickY = event.clientY
    element.addClass 'resizing'
    screenScale = $('.content').css('scale')

    $(window).on 'mouseup', (event) ->
      element.removeClass 'resizing'
      data =
        elementId: element.attr 'id'
        scale: elementScale element
        userId: userId
        final: true
      socket.emit 'updateElement', data


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
      
      # elementScale = $(this).css("scale")
      # header.css("scale": Math.max(+oldElementScale + newScale, 0.5))
      console.log(element.css("scale"))

      data =
        elementId: element.attr 'id'
        scale: elementScale element
        userId: userId
        final: false
      socket.emit 'updateElement', data

$ ->

  socket = io.connect()

  $('.ui-resizable-handle').on 'mousedown', resize socket






