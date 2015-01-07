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
    { content, contentType, caption } = element
    console.log 'NEW ELEMT CONTENT', content

    id = element.id
    x = element.x + totalDelta.x
    y = element.y + totalDelta.y
    z = element.z
    scale = element.scale

    titleDiv = ''
    captionDiv = ''

    if caption? and caption != ''
      captionDiv =
        "<div class='card text caption comment'>
          <p>#{caption}</p>
          <div class='background'></div>
          <div class='ui-resizable-handle ui-resizable-se ui-icon ui-icon-grip-diagonal-se'>
          </div>
        <div class='background'></div></div>"

    if contentType is 'image'
      innerHTML = () -> "<img src=#{content}>"
    else if contentType is 'website'
      innerHTML = () ->
        data = JSON.parse content
        url = decodeURIComponent data.url
        "<a href=\"#{url}\" target=\"_blank\">" +
          (if data.image? then "<div class='card image'><img src=\"#{data.image}\"></div>" else '')+
          "<div class='header card text'>
              <div class='title'>
                <p>#{data.title}</p>
              </div>
              <div class='url'>
                <p>#{data.domain}</p>
              </div>
              <div class='description'>
                <p>#{data.description}</p>
              </div>
           </div>
        </a>"
    else # type == text
      innerHTML = () -> "<p>#{content}</p>"
    
    newArticle =
      $("<article class='#{contentType}' id='#{id}' style='top:#{y}px;left:#{x}px;z-index:#{z};'>
        <a class='delete'></a>
        <div class='card #{contentType}'>
          #{innerHTML content}
          <div class='ui-resizable-handle ui-resizable-se'>
          </div>
        </div>
        #{captionDiv}
      </article>")
    $('.content').append newArticle
    makeDeletable newArticle
    $("\##{id}").draggable(draggableOptions socket)
      .css({
        "-webkit-transform-origin": "top left"
        "transform-origin": "top left"
        scale: scale
        })
    $('.ui-resizable-handle', "\##{id}").on 'mousedown', resize socket
    cluster()

    updateGlobals element

  socket.on 'removeElement', (data) ->
    id = data.id

    $("\##{id}").fadeOut -> 
      $(this).remove()

  socket.on 'updateElement', (data) ->
    element = data.element
    id = element.id
    # Make sure to account for screen drag
    x = element.x + totalDelta.x
    y = element.y + totalDelta.y
    z = element.z
    scale = element.scale

    window.maxZ +=1
    updateGlobals element

    $("\##{id}").css 'z-index', (window.maxZ)
    $("\##{id}").data 'oldZ', window.maxZ
    $("\##{id}").animate({ top: y, left: x }, cluster)
    $("\##{id}").transition { scale }

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
    
