onScreenDrag = (event) ->
  screenScale = $('.content').css 'scale'
  deltaX = (event.clientX - prev.x) / screenScale
  deltaY = (event.clientY - prev.y) / screenScale

  totalDelta.x += deltaX
  totalDelta.y += deltaY   

  prev.x = event.clientX
  prev.y = event.clientY
  $('article,.cluster').animate( { top: "+=#{deltaY}", left: "+=#{deltaX}" }, 0, 'linear' )

$ ->
  $(window).on 'mousedown', (event) ->
    window.prev =
      x: event.clientX
      y: event.clientY

    $(this).off 'mouseup'
    $(window).on 'mousemove', onScreenDrag
    $(window).on 'mouseup', ->
      $(event.target).removeClass 'dragging'
      $(this).off 'mousemove', onScreenDrag