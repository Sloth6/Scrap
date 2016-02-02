'use strict'
lengthForLong = 500

initText = ($article) ->
  timeout       = null
  emitInterval  = 500
  $article.data 'old-height', $article.children('card').height()

  onChange = (text) ->
    console.log $article.children('card')
    if timeout
      clearTimeout timeout 
      timeout = null

    timeout = setTimeout (() ->
      data =
        articleId: $article.attr('id')
        content: { text }

      socket.emit 'updateArticle', data
    ), emitInterval

  initGenericText $article, { onChange }
