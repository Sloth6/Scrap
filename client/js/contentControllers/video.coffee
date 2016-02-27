# initVideo = (elems) ->
#   videos = elems.find('video')

#   hoverIn  = () -> @setAttribute "controls", "controls"
#   hoverOut = () -> @removeAttribute "controls"
#   videos.hover hoverIn, hoverOut

#   videos.mousedown (e) ->
#     $(@).data 'lastX', e.clientX
#     $(@).data 'lastY', e.clientY

#   videos.mouseup (e) ->
#     return if $(@).data('lastX') != e.clientX
#     return if $(@).data('lastY') != e.clientY
#     if @paused then @play() else @pause()
