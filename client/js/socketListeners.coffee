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
    checkForNewCollection()
    switch element.data('contenttype')
      when 'text'
        makeModifiable element
      when 'video'
        bindVideoControls element
      when 'file'
        bindFileControls element
      when 'soundcloud'
        bindSoundCloudControls element

  socket.on 'removeElement', (data) ->
    id = data.id
    $("\##{id}").fadeOut -> 
      $(@).remove()

  socket.on 'updateElement', ({ spaceKey, userId, elementId, content }) ->
    return if data.userId is window.userId
    elem = $("\##{elementId}")
    elem.find('.editable').innerHTML element.content