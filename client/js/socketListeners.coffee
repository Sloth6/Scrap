$ ->  
  socket = io.connect()

  socket.on 'updateCollection', (data) ->
    name = data.name
    collectionKey = data.collectionKey
    $('h1').text(name)
    document.title = name
    $("a[href='/s/#{collectionKey}']").text(name)

  socket.on 'newArticle', (data) ->
    { html, collectionKey } = data
    $content = $(decodeURIComponent(html))
    console.log "new $content for #{collectionKey}", $content[0]
    $collection = $('.collection.open')
    
    if $collection.data('collectionkey') == collectionKey
      $addArticleForm = collectionModel.getAddForm $collection
      $content.css { x: xTransform($addArticleForm) }
      collectionModel.appendContent $collection, $content
      contentModel.init $content
      collectionViewController.draw $collection, {animate: true}
  
  socket.on 'newPack', (data) ->
    { coverHTML } = data
    $collection = $(decodeURIComponent(coverHTML))
    form = $('.addProjectForm')
    $collection.velocity { transformX: [xTransform(form), xTransform(form)] }

    collectionModel.appendContent $('.collection.open'), $collection
    contentModel.init $collection
    addProjectController.reset form
    collectionViewController.draw $('.collection.open')

  # for new stacks
  socket.on 'newCollection', (data) ->
    { draggedId, draggedOverId, coverHTML } = data
    console.log data
    dragged = $("##{data.draggedId}")
    draggedOver = $("##{data.draggedOverId}")
    stack = $(decodeURIComponent(data.coverHTML))
    
    stack.insertAfter draggedOver
    stack.css { x: xTransform(draggedOver), y: marginTop }
    draggedOver.remove()
    dragged.remove()

    contentModel.init stack

    setTimeout collectionRealignDontScale, 300
    console.log 'here all good'

  socket.on 'reorderArticles', (data) ->
    console.log 'reorderArticles', data

  socket.on 'deleteCollection', (data) ->
    { collectionKey } = data
    $collection =  $(".collection.#{collectionKey}")
    $collection.fadeOut ->
      $collection.remove()
      collectionViewController.draw $('.collection.open'), {animate: true}

  socket.on 'deleteArticle', (data) ->
    console.log 'deleteArticle', data, $("\##{data.id}")
    { id, collectionKey } = data
    
    toRemove = $("\##{data.id}")
    toRemove.fadeOut ->
      toRemove.remove()
      collectionViewController.draw $('.collection.open'), {animate: true}

  socket.on 'updateArticle', ({ collectionKey, userId, articleId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{articleId}")
    elem.find('.editable').innerHTML article.content

  # socket.on 'moveToCollection', ({ elemId, collectionKey }) ->
  #   $collectionFrom = contentModel.getCollection $("##{elemId}")
  #   $collectionTo = $(".collection.#{collectionKey}")
  #   console.log collectionFrom, collectionTo