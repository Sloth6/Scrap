resize = (socket) ->
  (event) ->
    # return if elem.hasClass 'locked'
    $(this).off 'mouseup'
    event.stopPropagation()
    element = $(this).parent().parent("article")
    clickX = event.clientX
    clickY = event.clientY
    element.addClass 'resizing'
    screenScale = $('.content').css('scale')
    window.dontAddNext = true
    
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
      element.css "scale": Math.max(+oldElementScale + newScale, 0.5)

      # Scale controls
      $(element).children('header, .resize').each () ->
        newHeaderScale = 1 / element.css("scale");
        $(this).attr('data-scale', newHeaderScale)
        scaleControls($(this), newHeaderScale, screenScale)
        
      data =
        elementId: element.attr 'id'
        scale: elementScale element
        userId: userId
        final: false
      socket.emit 'updateElement', data

makeResizeable = (elem, socket) ->
  elem.find('.ui-resizable-handle').on 'mousedown', resize socket

$ ->
  socket = io.connect()
  makeResizeable $('article'), socket
  