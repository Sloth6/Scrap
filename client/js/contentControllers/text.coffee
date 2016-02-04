'use strict'
lengthForLong = 500

initText = ($article) ->
  timeout       = null
  emitInterval  = 500
  oldHeight = $article.height()

  onChange = (text) ->

    if timeout
      clearTimeout timeout 
      timeout = null

    if $article.children('card').outerHeight() != oldHeight
      oldHeight = $article.children('.card').outerHeight()
      events.onArticleResize $article
      # $(constants.dom.articleContainer).packery()

    timeout = setTimeout (() ->
      data =
        articleId: $article.attr('id')
        content: { text }

      socket.emit 'updateArticle', data
    ), emitInterval

  initGenericText $article, { onChange }
