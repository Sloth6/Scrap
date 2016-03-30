window.contentControllers ?= {}

contentControllers.text =

  canZoom: true

  open: ($article) ->
    contentControllers.genericText.startEditing $article

  close: ($article) ->
    contentControllers.genericText.stopEditing $article
    if $article.data('haschangedsize')
      articleView.resize $article

  setLongShortClass: ($article) ->
    lengthForLong = 140
    oldHeight = $article.height()
    text = $article.find('.editable').text()

    if $article.children('card').outerHeight() != oldHeight
      oldHeight = $article.children('.card').outerHeight()

    if (text.length > lengthForLong)
      $article.addClass('long').removeClass('short')
    else
      $article.addClass('short').removeClass('long')


  init: ($article) ->
    timeout       = null
    emitInterval  = 500
    $article.data 'haschangedsize', false

    onChange = (html, text) ->
      $article.data 'haschangedsize', true
      if timeout
        clearTimeout timeout
        timeout = null
      contentControllers.text.setLongShortClass $article
      timeout = setTimeout (() ->
        articleId = $article.attr('id')
        content =  { text }
        socket.emit 'updateArticle', {articleId, text }
      ), emitInterval

    contentControllers.text.setLongShortClass $article
    $editable = $article.find('.editable')
    contentControllers.genericText.init $article, { onChange }

