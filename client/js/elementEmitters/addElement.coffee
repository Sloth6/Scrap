$ ->
  socket = io.connect()
  mouse = { x: 0, y: 0 }
  $(window).on 'dragover', (event) ->
    event = event.originalEvent
    scale = $('.content').css 'scale'
    mouse.x = (event.clientX - $('.content').offset().left) / scale
    mouse.y = (event.clientY - $('.content').offset().top) / scale

  window.oncontextmenu = () -> false

  $(window).mousedown (event) ->
    if event.which is 3 #right mouse
      event.preventDefault()
      $('.add-element').remove()
      addElement event, false
  $(window).on 'click', (event) -> $('.add-element').remove()
  $(window).bind 'paste', (event) ->
    if $('.add-element').length is 0
      addElement event, true
  
  # $(window).keypress (event) -> 
  #   if $('.add-element').length is 0
  #     addElement event, false

# 
  # The options for s3-streamed file uploads, used later
  fileuploadOptions = () ->
    # console.log x, y, scale
    multipart = false
    startData =
      x: 0
      y: 0
      scale: 1

    url: "http://scrapimagesteamnap.s3.amazonaws.com" # Grabs form's action src
    type: 'POST'
    autoUpload: true
    dataType: 'xml' # S3's XML response
    add: (event, data) ->
      startData.x = mouse.x
      startData.y = mouse.y
      startData.scale = $('.content').css 'scale'
      $.ajax "/sign_s3", {
        type: 'GET'
        dataType: 'json'
        data: {title: data.files[0].name, type: data.files[0].type} # Send filename to /signed for the signed response 
        async: false
        success: (data) ->
          # Now that we have our data, we update the form so it contains all
          # the needed data to sign the request
          $('input[name=key]').val data.key
          $('input[name=policy]').val data.policy
          $('input[name=signature]').val data.signature
          $('input[name=Content-Type]').val data.contentType
      }
      data.submit()

    send: (e, data) ->
      # Determine if this was a multiple upload
      if data.originalFiles.length > 1
        multipart = true

    progress: (e, data)->
      percent = Math.round((e.loaded / e.total) * 100)
      console.log 'progress', percent

    fail: (e, data) ->
      console.log 'fail', data

    success: (data) ->
      content = $(data).find('Location').text(); # Find location value from XML response
      emitElement startData.x, startData.y, 1/startData.scale, content


  # Initialize file uploads by dragging
  if $('.drag-upload').fileupload
    $('.drag-upload').fileupload fileuploadOptions()

  # adding a new element
  emitElement = (x, y, scale, content) ->
    # Make sure to account for screen drag (totalDelta)
    x = Math.round(x - totalDelta.x)
    y = Math.round(y - totalDelta.y)
    window.maxZ += 1
    z = window.maxZ
    content = encodeURIComponent content#.slice(0, -1)
    data = { content, x, y, z, scale, userId }
    socket.emit 'newElement', data

    $('.add-element').remove()
    $('.add-image').remove()
    $('.add-website').remove()

  addElement = (event, createdByCntrl) ->
    eventX = event.clientX || mouse.x
    eventY = event.clientY || mouse.y
    screenScale = $('.content').css('scale')
    scale = 1 / screenScale

    x = (eventX - $('.content').offset().left) / screenScale
    y = (eventY - $('.content').offset().top) / screenScale

    elementForm =
      "<article class='add-element'>
        <div class='card text comment'>
          <textarea name='content' class='new' placeholder=''></textarea>
        </div>
      </article>"

    # add the new element form if not createdByCntrl
    $('.content').append elementForm
    $('.add-element').on 'click', (event) -> event.stopPropagation()
      .css(
        scale: scale
        "transform-origin": "top left"
        'z-index': "#{window.maxZ + 1}"
        top: "#{y}px"
        left: "#{x}px")
    # allow file uploads
    # if not createdByCntrl
    #   $('.direct-upload').fileupload fileuploadOptions x, y, null, screenScale

    $('textarea.new').focus().autoGrow()
    
    if createdByCntrl
      setTimeout(() ->
        content = $('.add-element .new').val()
        emitElement x, y, scale, content
      , 20)
    else 
      $('textarea.new').on 'keyup', (event) ->
          # on enter (not shift + enter)
          if event.keyCode is 13 and not event.shiftKey
            content = $('.add-element .new').val()
            emitElement x, y, scale, content