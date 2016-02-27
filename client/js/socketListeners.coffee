'use strict'
$ ->
  socket = io.connect()

  socket.on 'newArticle', (data) ->
    { html } = data
    $article = $(decodeURIComponent(html))
    console.log "new $article", $article.attr('class')
    containerController.addArticles $article
    articleController.init $article

  socket.on 'newCollection', (data) ->
    console.log 'socket.on.newCollection', data
    { name, collectionKey, color } = data
    if !(name? and collectionKey? and color?)
      throw 'Invalid parameters sent on newCollection'
    collections[collectionKey] = data
    collectionsMenuController.add name, collectionKey, color

  # socket.on 'deleteCollection', (data) ->
  #   { collectionKey } = data
  #   $collection =  $(".collection.#{collectionKey}")
  #   $collection.fadeOut ->
  #     $collection.remove()
  #     collectionViewController.draw $('.collection.open'), {animate: true}
  #     size = contentModel.getSize $('.collection.open')
  #     $(document.body).css { width: size }

  socket.on 'deleteArticle', (data) ->
    console.log 'deleteArticle', data, $("\##{data.id}")
    { id } = data
    if !(id)
      throw 'Invalid parameters sent on deleteArticle'

    containerController.removeArticle $("##{id}")

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
