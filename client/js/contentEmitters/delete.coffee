onDelete = ($content) ->
#   console.log 'about to delete', $content
  if $content.hasClass('collection')
    parentCollection = contentModel.getCollection $content
    if confirm('Are you sure you want to delete everything in this Pack?')
      collectionKey = collectionModel.getState($content).collectionKey
      parentCollectionKey = collectionPath[1]  
      socket.emit 'deleteCollection', { collectionKey }
    else
      setTimeout () ->
        collectionViewController.draw parentCollection, { animate: true }
      , defaultDuration
  else
    articleId = $content.attr 'id'
    $collection = contentModel.getCollection $content
    collectionKey  = $collection.data 'collectionkey'
    parentCollectionKey = collectionPath[1]
    console.log 'deleting!', $content, $collection, articleId, collectionKey, parentCollectionKey 
    socket.emit 'deleteArticle', { articleId, collectionKey, parentCollectionKey }

# makeDeletable = ($content) ->
#   $content.each () ->
#     if $(@).hasClass('collection')
#       deleteButton = $(@).children('.cover').find('.articleDeleteButton')
#     else
#       deleteButton = $(@).find('.articleDeleteButton')
# 
#     deleteButton.click (event) =>
#       event.stopPropagation()
#       onDelete $(@)