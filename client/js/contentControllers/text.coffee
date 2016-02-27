lengthForLong = 500
window.contentControllers ?= {}

contentControllers['text'] =
  canZoom: true

  open: ($article) ->
    contentControllers.genericText.startEditing $article

  close: ($article) ->
    contentControllers.genericText.stopEditing $article

  init: ($article) ->
    timeout       = null
    emitInterval  = 500
    oldHeight = $article.height()

    onChange = (text) ->
      if timeout
        clearTimeout timeout
        timeout = null

      if $article.children('card').outerHeight() != oldHeight
        oldHeight = $article.children('.card').outerHeight()
        # events.onArticleResize $article

      timeout = setTimeout (() ->
        data =
          articleId: $article.attr('id')
          content: { text }

        socket.emit 'updateArticle', data
      ), emitInterval

    contentControllers.genericText.init $article, { onChange }

