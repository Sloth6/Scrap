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
    $(".collection.#{spaceKey} .elements").prepend element
    collection_init.call $(".collection.#{spaceKey}")
    # switch contentType
    #   when 'text'
    #     makeModifiable element, socket
    #   when 'video'
    #     bindVideoControls element
    #   when 'file'
    #     bindFileControls element
    #   when 'soundcloud'
    #     bindSoundCloudControls element

  socket.on 'removeElement', (data) ->
    id = data.id
    $("\##{id}").fadeOut -> 
      $(@).remove()

  socket.on 'updateElement', (data) ->
    return if data.userId is window.userId
    element = data.element
    final = data.final
    id = element.id
    elem = $("\##{id}")
    if element.content
      elem.children('.card.text.comment').children('p').html element.content