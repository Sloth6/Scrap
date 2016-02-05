'use strict'
$ ->  
  socket = io.connect()

  socket.on 'newArticle', (data) ->
    { html } = data
    $article = $(decodeURIComponent(html))
    console.log "new $article", $article.attr('class')    
    $(constants.dom.articleContainer).prepend $article
    init.article $article
    $(constants.dom.articleContainer).packery 'prepended', $article

  socket.on 'newCollection', (data) ->
    console.log 'socket.on.newCollection', data
    { name, collectionKey, color } = data
    collections[collectionKey] = data
    $('li.newCollection')

  # socket.on 'deleteCollection', (data) ->
  #   { collectionKey } = data
  #   $collection =  $(".collection.#{collectionKey}")
  #   $collection.fadeOut ->
  #     $collection.remove()
  #     collectionViewController.draw $('.collection.open'), {animate: true}
  #     size = contentModel.getSize $('.collection.open')
  #     $(document.body).css { width: size }

  # socket.on 'deleteArticle', (data) ->
  #   console.log 'deleteArticle', data, $("\##{data.id}")
  #   { id, collectionKey } = data
    
  #   toRemove = $("\##{data.id}")
  #   toRemove.fadeOut ->
  #     toRemove.remove()
  #     collectionViewController.draw $('.collection.open'), {animate: true}
  #     size = contentModel.getSize $('.collection.open')
  #     $(document.body).css { width: size }

  socket.on 'updateArticle', ({ collectionKey, userId, articleId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{articleId}")
    elem.find('.editable').innerHTML article.content
