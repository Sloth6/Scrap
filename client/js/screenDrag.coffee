onScreenDrag = (event) ->
  screenScale = $('.content').css 'scale'
  deltaX = (event.clientX - prev.x) / screenScale
  deltaY = (event.clientY - prev.y) / screenScale

  totalDelta.x += deltaX
  totalDelta.y += deltaY   

  prev.x = event.clientX
  prev.y = event.clientY
  $('article,.cluster').animate( { top: "+=#{deltaY}", left: "+=#{deltaX}" }, 0, 'linear' )
