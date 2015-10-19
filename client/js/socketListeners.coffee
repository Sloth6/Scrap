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
        css({x: xTransform(element), y: sliderMarginTop}).
        addClass('sliding')

      sliderInit element
      collectionRealign.call $('.slidingContainer')
      
  socket.on 'newCollection', (data) ->
    { draggedId, draggedOverId, coverHTML } = data
    dragged = $("##{data.draggedId}")
    draggedOver = $("##{data.draggedOverId}")
    cover = $(decodeURIComponent(data.coverHTML))

    cover.insertAfter draggedOver
    cover.css {x: xTransform(draggedOver), y: sliderMarginTop}
    draggedOver.remove()
    dragged.remove()
    $("##{draggedOverId}").remove()
    sliderInit cover
    collectionRealign.call $('.slidingContainer')


  socket.on 'removeElement', (data) ->
    console.log 'removeElement', data
    elem = $("\##{data.id}")    
    elem.fadeOut -> 
      elem.remove()
      collectionRealign.call $('.slidingContainer')

  socket.on 'updateElement', ({ spaceKey, userId, elementId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{elementId}")
    elem.find('.editable').innerHTML element.content
