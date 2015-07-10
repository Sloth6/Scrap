bindSoundCloudControls = (elems) ->
  elems.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  elems.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    img = $(@).find('img')
    if img.length
      iframe = $($(@).data('content').html)
      iframe.load () -> 
        widget = SC.Widget(@)
        widget.bind SC.Widget.Events.READY, () -> widget.toggle()
      iframe.insertAfter img
      img.remove()

    else
      SC.Widget($(@).find('iframe')[0]).toggle()
      
