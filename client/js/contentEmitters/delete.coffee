onDelete = ($content) ->
  # console.log 'deleting', $content
  # return
  if $content.hasClass('collection')
    if confirm('Delete everything?')
      collectionKey = collectionModel.getState($content).collectionKey
      parentCollectionKey = collectionPath[1]  
      socket.emit 'deleteCollection', { collectionKey }
  else
    articleId = $content.attr 'id'
    $collection = contentModel.getCollection $content
    collectionKey  = $collection.data 'collectionkey'
    parentCollectionKey = collectionPath[1]
    socket.emit 'deleteArticle', { articleId, collectionKey, parentCollectionKey }

makeDeletable = ($content) ->
  $content.each () ->
    $(@).find('.articleDeleteButton').click (event) =>
      event.stopPropagation()
      onDelete $(@)