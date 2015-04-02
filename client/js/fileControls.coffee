makeDownloadable = (e) ->
  downloadURI = (uri, name) ->
    link = document.createElement "a"
    link.download = name
    link.href = uri
    link.click()
  $(e).click () ->
    uri = $(@).data('content')
    name = uri.split('/').pop()
    downloadURI uri, name

$ ->
  $('.card.file').each () -> makeDownloadable @
    