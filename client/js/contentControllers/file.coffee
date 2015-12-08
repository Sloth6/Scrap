initFile = (article) ->
  button = article.find('a.download')
  
  button.mousedown (event) ->
    $(@).data 'lastX', event.clientX
    $(@).data 'lastY', event.clientY

  button.mouseup (event) ->
    return if $(@).data('lastX') != event.clientX
    return if $(@).data('lastY') != event.clientY
    event.preventDefault()
    uri = article.data 'content'
    name = uri.split('/').pop()
    link = document.createElement "a"
    link.download = name
    link.href = uri
    link.click()
