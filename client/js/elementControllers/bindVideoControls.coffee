bindVideoControls = (elems) ->
  videos = elems.find('video')
  hoverIn  = () -> @setAttribute "controls", "controls"
  hoverOut = () -> @removeAttribute "controls"
  videos.hover hoverIn, hoverOut
  videos.click () -> if @paused then @play() else @pause()