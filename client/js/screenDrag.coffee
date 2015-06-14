$ ->
  $(window).on 'mousedown', (event) ->
    return unless $(event.target).hasClass('container')

    prev =
      x: event.clientX
      y: event.clientY

    $(event.target).addClass('dragging')
    onScreenDrag = (event) ->

      screenScale = $('.content').css 'scale'
      deltaX = (event.clientX - prev.x) / screenScale
      deltaY = (event.clientY - prev.y) / screenScale

      totalDelta.x += deltaX
      totalDelta.y += deltaY   

      prev.x = event.clientX
      prev.y = event.clientY
      $('article,.cluster').animate( { top: "+=#{deltaY}", left: "+=#{deltaX}" }, 0, 'linear' )
  
    $(this).off 'mouseup'
    $(window).on 'mousemove', onScreenDrag
    $(window).on 'mouseup', ->
      $(event.target).removeClass 'dragging'
      $(this).off 'mousemove', onScreenDrag