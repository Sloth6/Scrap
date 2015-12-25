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
  collectionKey  = $content.data 'collectionkey'
  articleId = $content.attr 'id'
  timeout   = null
  emitInterval = 200

  onChange = (text) ->
    textFormat $content
    clearTimeout timeout if timeout
    timeout = setTimeout (() ->
      socket.emit 'updateArticle', { collectionKey, userId, articleId, content:text }
    ), emitInterval

  initGenericText $content, { onChange }
  
  # if $content.find('.editable').text().length < lengthForLong
  #   $content.addClass 'short'
  # else
  #   $content.addClass 'long'
