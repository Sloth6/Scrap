bindFileControls = (elems) ->
  elems.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  elems.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    uri = $(@).data 'content'
    name = uri.split('/').pop()
    link = document.createElement "a"
    link.download = name
    link.href = uri
    link.click()
