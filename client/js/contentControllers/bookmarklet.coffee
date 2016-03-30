window.contentControllers ?= {}
contentControllers.bookmarklet =
  canZoom: false
  init: (article) ->
    $(article).find('a').click (event) ->
      event.preventDefault()
