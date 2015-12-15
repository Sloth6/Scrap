$ ->  
  socket = io.connect()

  socket.on 'updateCollection', (data) ->
    name = data.name
    collectionKey = data.collectionKey
    $('h1').text(name)
    document.title = name
    $("a[href='/s/#{collectionKey}']").text(name)

  socket.on 'newArticle', (data) ->
    {collectionKey, html} = data
    $article = $(decodeURIComponent(html))

    console.log "new $article for #{collectionKey}", $article.attr('class')
    
    $collection = $('.collection.open')
    if collectionModel.getState($collection).collectionKey == collectionKey
      $addArticleForm = collectionModel.getAddForm $collection
      $article.css { x: xTransform($addArticleForm) }
      collectionModel.appendContent $collection, $article
      contentModel.init $article
      collectionViewController.draw $collection, { animate: true }
      size = contentModel.getSize $collection
      $(document.body).css { width: size }

  socket.on 'newPack', (data) ->
    { collectionHTML } = data
    $collection = $(decodeURIComponent(collectionHTML))
    $form = collectionModel.getAddForm $('.collection.root')

    collectionModel.appendContent $('.collection.open'), $collection
    $collection.css { x: xTransform($form) }
    contentModel.init $collection
    addProjectController.reset $form
    collectionViewController.draw $('.collection.open'), {animate: true}

  # for new stacks
  socket.on 'newCollection', (data) ->
    { draggedId, draggedOverId, collectionHTML } = data
    
    
    dragged = $("##{data.draggedId}")
    draggedOver = $("##{data.draggedOverId}")
    
    # Make these elements no longer interactive.
    # dragged.add(draggedOver).off()

    $stack = $(decodeURIComponent(data.collectionHTML))
    $stack.insertAfter draggedOver
    $stack.css { x: xTransform(draggedOver) }

    collectionModel.appendContent $stack, draggedOver
    collectionModel.appendContent $stack, dragged
    
    contentModel.init $stack
    collectionViewController.draw $('.collection.open')

  socket.on 'reorderArticles', (data) ->
    console.log 'reorderArticles', data

  socket.on 'deleteCollection', (data) ->
    { collectionKey } = data
    $collection =  $(".collection.#{collectionKey}")
    $collection.fadeOut ->
      $collection.remove()
      collectionViewController.draw $('.collection.open'), {animate: true}
      size = contentModel.getSize $('.collection.open')
      $(document.body).css { width: size }

  socket.on 'deleteArticle', (data) ->
    console.log 'deleteArticle', data, $("\##{data.id}")
    { id, collectionKey } = data
    
    toRemove = $("\##{data.id}")
    toRemove.fadeOut ->
      toRemove.remove()
      collectionViewController.draw $('.collection.open'), {animate: true}
      size = contentModel.getSize $('.collection.open')
      $(document.body).css { width: size }


  socket.on 'updateArticle', ({ collectionKey, userId, articleId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{articleId}")
    elem.find('.editable').innerHTML article.content

  # socket.on 'moveToCollection', ({ elemId, collectionKey }) ->
  #   $collectionFrom = contentModel.getCollection $("##{elemId}")
  #   $collectionTo = $(".collection.#{collectionKey}")
  #   console.log collectionFrom, collectionTo