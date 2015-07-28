$ ->  
  socket = io.connect()

  socket.on 'updateSpace', (data) ->
    name = data.name
    spaceKey = data.spaceKey
    $('h1').text(name)
    document.title = name
    $("a[href='/s/#{spaceKey}']").text(name)

  socket.on 'newElement', (data) ->
    html = decodeURIComponent data.element
    element = createNewElement html
    updateGlobals element
    url = element.data('content').split('/').pop()
    removeLoadingElement url

  socket.on 'removeElement', (data) ->
    id = data.id
    $("\##{id}").fadeOut -> 
      $(this).remove()

  socket.on 'updateElement', (data) ->
    return if data.userId is window.userId
    element = data.element
    final = data.final
    id = element.id
    elem = $("\##{id}")
    if element.content
      elem.children('.card.text.comment').children('p').html element.content