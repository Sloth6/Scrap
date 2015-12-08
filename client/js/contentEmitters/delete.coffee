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
    if $(@).hasClass('collection')
      deleteButton = $(@).children('.cover').find('.articleDeleteButton')
    else
      deleteButton = $(@).find('.articleDeleteButton')

    deleteButton.click (event) =>
      event.stopPropagation()
      onDelete $(@)