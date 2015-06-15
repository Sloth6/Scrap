$ ->
  $('.back').click () -> history.back()
  history.pushState {name: "metaspace"}, "", "/"
  window.onpopstate = (event) ->
    if event.state?
      page = event.state.name
      if page is 'metaspace'
        closeSpace()
      else if page.match(/\/s\/([a-z0-9]+)$/)?
        spaceKey = page.match(/^\/s\/([a-z0-9]+)$/)[1]
        enterSpace spaceKey, $(".spacePreview.#{spaceKey}")