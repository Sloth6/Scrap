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
    element = $(decodeURIComponent(html))
    console.log "new element for #{spaceKey}", element
    
    if $(".#{spaceKey}.collection").hasClass 'open'
      element.
        insertAfter($(".#{spaceKey}.collection").find('.addElementForm')).
        css({x: xTransform(element)}).
        addClass('sliding')

      sliderInit element
      collectionRealign.call $('.slidingContainer')
      
  socket.on 'newCollection', (data) ->
    { draggedId, draggedOverId, coverHTML } = data
    dragged = $("##{data.draggedId}")
    draggedOver = $("##{data.draggedOverId}")
    cover = $(decodeURIComponent(data.coverHTML))
    stack = stackCreate cover
    
    stack.add draggedOver
    stack.add dragged
    
    stack.insertAfter draggedOver
    stack.css {x: xTransform(draggedOver), y: marginTop}
    
    draggedOver.remove()
    dragged.remove()
    $("##{draggedOverId}").remove()
    sliderInit stack
    collectionRealign.call $('.slidingContainer')

  socket.on 'reorderElements', (data) ->
    console.log 'reorderElements', data

  socket.on 'removeElement', (data) ->
    console.log 'removeElement', data, $("\##{data.id}")
    { id, spaceKey } = data
    
    toRemove = $("\##{data.id}")
    toRemove.fadeOut ->
      # if removing the open collection
      if toRemove.hasClass('stack') and toRemove.hasClass('open')
        collection = $('.open.collection')
        children = collectionChildren(collection).not('.addElementForm')
        children.insertAfter collection
        collectionClose(deleteAfter: true)
      
        toRemove.remove()
        collectionRealign()
    #   # collectionRealign()
    #   if $(@).hasClass('stack open')
    #     console.log 'need to close this collection!'
      #   children = collectionChildren($(@)).not('.addElementForm')
      #   children.insertAfter $('.collection.open')
      #   collectionClose()
      # $(@).remove()
      # collection = $('.open.collection')
      # return unless $('.open.collection').hasClass spaceKey
      # children = collectionChildren(collection).not('.addElementForm')
      # if children.length == 1
      #   console.log 'time to colappse'
      #   children.first().insertAfter $('.collection.open')
      #   collectionRemove()
        # collectionClose(children.first())
        
      # if 
    # stack = $('.stack').filter( -> $(@).data('content').spaceKey == spaceKey)
    # stackUpdate stack

  socket.on 'updateElement', ({ spaceKey, userId, elementId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{elementId}")
    elem.find('.editable').innerHTML element.content
