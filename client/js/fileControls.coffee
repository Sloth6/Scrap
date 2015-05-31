downloadURI = (uri, name) ->
  link = document.createElement "a"
  link.download = name
  link.href = uri
  link.click()

makeDownloadable = (elem) ->
  lastX = null
  lastY = null

  elem.mousedown (e) ->
    lastX = e.clientX
    lastY = e.clientY

  elem.mouseup (e) ->
    if e.clientX is lastX and e.clientY is lastY
      uri = elem.data 'content'
      name = uri.split('/').pop()
      downloadURI uri, name

$ ->
  $('.file').each () -> makeDownloadable $(@)
    