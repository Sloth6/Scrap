lengthForLong = 500

textFormat = (elems) ->
  elems.each () ->
    editable = $(@).find('.editable')

    if editable.text().length < lengthForLong and !$(@).hasClass('short')
      $(@).addClass('short').removeClass('long')
      collectionViewController.draw $('.collection.open')
    
    else if editable.text().length > lengthForLong and !$(@).hasClass('long')
      $(@).addClass('long').removeClass('short')
      collectionViewController.draw $('.collection.open')

initText = ($content) ->
  timeout       = null
  emitInterval  = 200
  collectionKey = contentModel.getCollectionkey $content

  onChange = (text) ->
    textFormat $content
    clearTimeout timeout if timeout
    timeout = setTimeout (() ->
      data =
        collectionKey: collectionKey
        userId: window.userId
        articleId: $content.attr('id')
        content: text
      socket.emit 'updateArticle', data
    ), emitInterval

  initGenericText $content, { onChange }
