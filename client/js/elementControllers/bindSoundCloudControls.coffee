bindSoundCloudControls = (elems) ->
  elems.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  elems.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    SC.Widget($(@).find('iframe')[0]).toggle()
