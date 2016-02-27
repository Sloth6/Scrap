window.contentControllers ?= {}
contentControllers['file'] =
  canZoom: false
  init: (article) ->
    button = article.find('a.download')
    button.click (event) ->
      event.preventDefault()
      uri = article.data 'content'
      name = uri.split('/').pop()
      link = document.createElement "a"
      link.download = name
      link.href = uri
      link.click()
