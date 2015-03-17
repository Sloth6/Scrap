$ ->
  socket = io.connect()
  mouse = { x: 0, y: 0 }
  $(window).on 'dragover', (event) ->
    event = event.originalEvent
    # scale = $('.content').css 'scale'
    mouse.x = event.clientX#(event.clientX - $('.content').offset().left) / scale
    mouse.y = event.clientY#(event.clientY - $('.content').offset().top) / scale
  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

    # scale = $('.content').css 'scale'
    # mouse.x = (event.clientX - $('.content').offset().left) / scale
    # mouse.y = (event.clientY - $('.content').offset().top) / scale

  window.oncontextmenu = () -> false

  $(window).mousedown (event) ->
    if event.which is 3 #right mouse
      event.preventDefault()
      $('.add-element').remove()
      addElement event, false
  
  $(window).on 'click', (event) ->
    $('.add-element').remove()
  
  $(window).bind 'paste', (event) ->
    # ensure the add element panel is not already open.
    if $('.add-element').length is 0
      addElement event, true
  
  # $(window).keypress (event) -> 
  #   if $('.add-element').length is 0
  #     addElement event, false

# 
  # The options for s3-streamed file uploads, used later
  fileuploadOptions = () ->
    multipart = false
    startData =
      x: 0
      y: 0
      scale: 1

    url: "http://scrapimagesteamnap.s3.amazonaws.com" # Grabs form's action src
    type: 'POST'
    autoUpload: true
    dataType: 'xml' # S3's XML response
    add: (event, add_data) ->
      screenScale = $('.content').css 'scale'
      startData.x = (mouse.x - $('.content').offset().left) / screenScale
      startData.y = (mouse.y - $('.content').offset().top) / screenScale
      startData.scale = screenScale

      $.ajax "/sign_s3", {
        type: 'GET'
        dataType: 'json'
        data:# Send filename to /signed for the signed response 
          title: add_data.files[0].name
          type: add_data.files[0].type
          spaceKey: spaceKey

        async: false
        success: (success_data) ->
          file_name = success_data.key.split('/').pop().split('.')[0]
          createLoadingElement startData, file_name
          # Now that we have our data, we update the form so it contains all
          # the needed data to sign the request
          $('input[name=key]').val success_data.key
          $('input[name=policy]').val success_data.policy
          $('input[name=signature]').val success_data.signature
          $('input[name=Content-Type]').val success_data.contentType
      }
      add_data.submit()

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
      content = decodeURIComponent $(data).find('Location').text(); # Find location value from XML response
      emitElement startData.x, startData.y, content

  # Initialize file uploads by dragging
  if $('.drag-upload').fileupload
    $('.drag-upload').fileupload fileuploadOptions()

  # adding a new element
  emitElement = (x, y, content) ->
    # Make sure to account for screen drag (totalDelta)
    x = Math.round(x - totalDelta.x)
    y = Math.round(y - totalDelta.y)
    window.maxZ += 1
    z = window.maxZ
    content = encodeURIComponent content
    if content != ''
      data = { content, x, y, z, userId }
      socket.emit 'newElement', data

    $('.add-element').remove()

  addElement = (event, createdByPaste) ->
    eventX = event.clientX || mouse.x
    eventY = event.clientY || mouse.y
    scale = 1 / $('.content').css('scale')
    x = (eventX - $('.content').offset().left) * scale
    y = (eventY - $('.content').offset().top) * scale

    elementForm =
      "<article class='add-element'>
        <div class='card text comment'>
          <textarea name='content' class='new' placeholder=''></textarea>
        </div>
      </article>"

    # add the new element form if not createdByCntrl
    $('.content').append elementForm
    $('.add-element')
      .css
        scale: scale
        "transform-origin": "top left"
        'z-index': "#{window.maxZ + 1}"
        top: "#{y}px"
        left: "#{x}px"
      .on 'click', (event) -> event.stopPropagation()
    # allow file uploads
    # if not createdByPaste
    #   $('.direct-upload').fileupload fileuploadOptions x, y, null, screenScale

    $('textarea.new').focus().autoGrow()
 
    if createdByCntrl
      setTimeout(() ->
        content = $('.add-element .new').val()
        emitElement x, y, content
      , 20)
    else 
      $('textarea.new').on 'keyup', (event) ->
          # on enter (not shift + enter)
          if event.keyCode is 13 and not event.shiftKey
            content = $('.add-element .new').val()
            emitElement x, y, content