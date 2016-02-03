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

    if $article.children('card').height() != oldHeight
      oldHeight = $article.children('.card').height()
      $article.height oldHeight
      $('#container').packery()

    timeout = setTimeout (() ->
      data =
        articleId: $article.attr('id')
        content: { text }

      socket.emit 'updateArticle', data
    ), emitInterval

  initGenericText $article, { onChange }
