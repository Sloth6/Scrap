$ ->  
  socket = io.connect()

  socket.on 'updateSpace', (data) ->
    name = data.name
    spaceKey = data.spaceKey
    $('h1').text(name)
    document.title = name
    $("a[href='/s/#{spaceKey}']").text(name)

  socket.on 'newElement', (data) ->
    { html, spaceKey } = data
    $content = $(decodeURIComponent(html))
    console.log "new $content for #{spaceKey}", $content[0]
    $collection = $('.collection.open')
    
    if $collection.data('spacekey') == spaceKey
      $addElementForm = collectionModel.getAddForm $collection
      $content.css { x: xTransform($addElementForm) }
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
    # stack.add draggedOver
    # stack.add dragged
    stack.css { x: xTransform(draggedOver), y: marginTop }
    draggedOver.remove()
    dragged.remove()

    contentModel.init stack

    setTimeout collectionRealignDontScale, 300
    console.log 'here all good'
    # console.log stack[0]

  socket.on 'reorderElements', (data) ->
    console.log 'reorderElements', data

  socket.on 'deleteCollection', (data) ->
    { spaceKey } = data
    $collection =  $(".collection.#{spaceKey}")
    $collection.fadeOut ->
      $collection.remove()
      collectionViewController.draw $('.collection.open'), {animate: true}

  socket.on 'removeElement', (data) ->
    console.log 'removeElement', data, $("\##{data.id}")
    { id, spaceKey } = data
    
    toRemove = $("\##{data.id}")
    toRemove.fadeOut ->
      toRemove.remove()
      collectionViewController.draw $('.collection.open'), {animate: true}

  socket.on 'updateElement', ({ spaceKey, userId, elementId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{elementId}")
    elem.find('.editable').innerHTML element.content

  # socket.on 'moveToCollection', ({ elemId, spaceKey }) ->
  #   $collectionFrom = contentModel.getCollection $("##{elemId}")
  #   $collectionTo = $(".collection.#{spaceKey}")
  #   console.log collectionFrom, collectionTo