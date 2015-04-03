makeDownloadable = (e) ->
  downloadURI = (uri, name) ->
    link = document.createElement "a"
    link.download = name
    link.href = uri
    link.click()

  lastX = null
  lastY = null

  $(e).mousedown (e) ->
    lastX = e.clientX
    lastY = e.clientY

  $(e).mouseup (e) ->
    if e.clientX is lastX and e.clientY is lastY
      uri = $(@).data('content')
      name = uri.split('/').pop()
      downloadURI uri, name

$ ->
  $('.card.file').each () -> makeDownloadable @
    