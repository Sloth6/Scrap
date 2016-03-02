window.contentControllers ?= {}

contentControllers['text'] =
  canZoom: true

  open: ($article) ->
    contentControllers.genericText.startEditing $article

  close: ($article) ->
    contentControllers.genericText.stopEditing $article
    if $article.data('haschangedsize')
      articleView.resize $article

  init: ($article) ->
    timeout       = null
    emitInterval  = 500
    lengthForLong = 140
    oldHeight = $article.height()
    $article.data 'haschangedsize', false

    onChange = (html, text) ->
      $article.data 'haschangedsize', true
      if timeout
        clearTimeout timeout
        timeout = null

      if $article.children('card').outerHeight() != oldHeight
        oldHeight = $article.children('.card').outerHeight()

      console.log text.length
      if (text.length > lengthForLong)
        $article.addClass('long').removeClass('short')
      else
        $article.addClass('short').removeClass('long')


      timeout = setTimeout (() ->
        data =
          articleId: $article.attr('id')
          content: { text }
        socket.emit 'updateArticle', data

      ), emitInterval

    $editable = $article.find('.editable')
    onChange($editable[0].innerHTML, $editable.text())
    contentControllers.genericText.init $article, { onChange }

