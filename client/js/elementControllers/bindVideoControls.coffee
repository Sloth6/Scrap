bindVideoControls = (elems) ->
  videos = elems.find('video')
  hoverIn  = () -> @setAttribute "controls", "controls"
  hoverOut = () -> @removeAttribute "controls"
  videos.hover hoverIn, hoverOut

  elems.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  elems.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    videos.click () -> if @paused then @play() else @pause()