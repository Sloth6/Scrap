$ ->  
  socket = io.connect()

  socket.on 'updateSpace', (data) ->
    name = data.name
    spaceKey = data.spaceKey

    $('h1').text(name)
    document.title = name
    $("a[href='/s/#{spaceKey}']").text(name)

  socket.on 'addUserToSpace', (data) ->
    if data?
      $('li', '.users').first().before "<li>#{data.name}</li>"

  socket.on 'removeUserFromSpace', (data) ->
    $('li[data-id="' + data.id + '"]').fadeOut -> 
      $(this).remove()

  socket.on 'newElement', (data) ->
    element = data.element
    createNewElement element

  socket.on 'removeElement', (data) ->
    id = data.id
    $("\##{id}").fadeOut -> 
      $(this).remove()

  socket.on 'updateElement', (data) ->
    if data.userId == window.userId
      return
    element = data.element
    final = data.final
    id = element.id
    elem = $("\##{id}")
    
    if final
      elem.removeClass 'locked'
      elem.draggable 'enable'
    else
      elem.addClass 'locked'
      elem.draggable 'disable'

    # Make sure to account for screen drag
    if element.x and element.y
      x = element.x + totalDelta.x
      y = element.y + totalDelta.y
      elem.css { top: y, left: x }
    # if element.z
    #   z = element.z
    if element.scale?
      scale = element.scale
      elem.css { scale }
      # elem.transition { scale }
    if element.content
      elem.children('.card.text.comment').children('p').html element.content
      # ...
    

    # window.maxZ +=1
    updateGlobals element

    elem.css 'z-index', data.element.z
    elem.data 'oldZ', window.maxZ
    makeTextChild elem
    # $("\##{id}").animate({ top: y, left: x }, cluster)
    

  updateGlobals = (element) ->
    if (element.x + 300 * element.scale) > window.maxX
      window.maxX = (element.x + 300 * element.scale)

    if element.x < window.minX
      window.minX = element.x

    if element.y > window.maxY
      window.maxY = element.y

    if element.y < window.minY
      window.minY = element.y

    if element.scale < window.minScale
      window.minScale = element.scale
    
