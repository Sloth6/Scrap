$ ->
  socket = io.connect()
  mouse = { x: 0, y: 0 }

  # On document so that it doesn't get messed up by screenDrag
  $(document).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

  window.oncontextmenu = () -> false
  $(window).mousedown (event) ->
    if event.which is 3 #right mouse
      event.preventDefault()
      $('.add-element').remove()
      addElement event, false

  $(window).on 'click', (event) -> $('.add-element').remove()
  $(window).bind 'paste', (event) -> addElement event, true
  
  $(window).keypress (event) -> 
    if $('.add-element').length is 0
      addElement event, false

# 
  # The options for s3-streamed file uploads, used later
  fileuploadOptions = (x, y, contentType, scale) ->
    multipart = false
    url: "http://scrapimagesteamnap.s3.amazonaws.com" # Grabs form's action src
    type: 'POST'
    autoUpload: true
    dataType: 'xml' # S3's XML response
    add: (event, data) ->
      # console.log data
      title = data.files[0].name or null
      type = data.files[0].type or null
      $.ajax "/sign_s3", {
        type: 'GET'
        dataType: 'json'
        data: { title, type } # Send filename to /signed for the signed response 
        async: false
        success: (data) ->
          # Now that we have our data, we update the form so it contains all
          # the needed data to sign the request
          contentType = data.contentType.split('/')[0]

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
      # On drag-to-upload, these variables won't have been set yet, so let's set them
      scale ||= $('.content').css 'scale'
      x ||= Math.round((x - 128 - $('.content').offset().left) / scale)
      y ||= Math.round((y - $('.content').offset().top) / scale)

      content = $(data).find('Location').text(); # Find location value from XML response
      console.log 'success', content, contentType

      # If multiple files were uploaded, don't add caption boxes for all of them
      # if multipart
      emitElement x, y, 1/scale, content, contentType
      # else
      #   innerHTML = (content) -> "<img src='#{content}'>"
      #   addCaption x, y, 1/scale, contentType, content, innerHTML

      # Reset variables for next drag-upload
      # x  = y = scale = null

  # Initialize file uploads by dragging
  if $('.drag-upload').fileupload
    $('.drag-upload').fileupload fileuploadOptions(mouse.x, mouse.y, null, $('.content').css('scale'))

  # adding a new element
  emitElement = (x, y, scale, content, contentType) ->
    # Make sure to account for screen drag (totalDelta)
    x = Math.round(x - totalDelta.x)
    y = Math.round(y - totalDelta.y)
    caption = $('textarea[name=caption]').val()
    caption = if caption? then caption.slice(0, -1) else caption # remove last newline 
    window.maxZ += 1
    z = window.maxZ
    data = { contentType, content, x, y, z, scale, caption, userId }
    socket.emit 'newElement', data

    $('.add-element').remove()
    $('.add-image').remove()
    $('.add-website').remove()

  isWebsite = (url) ->
    expression = /[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi
    !!url.match expression

  # on double-click, append new element form, then process the new element if one is submitted

  # $('.container').mouseup (event) ->
  #   screenScale = $('.content').css('scale') 
  #   elementScale = 1 / screenScale
  #   x = (event.clientX - $('.content').offset().left) / screenScale
  #   y = (event.clientY - $('.content').offset().top) / screenScale
    # console.log(screenScale)

  addElement = (event, createdByPaste) ->
    eventX = event.clientX || mouse.x
    eventY = event.clientY || mouse.y
    screenScale = $('.content').css('scale')
    scale = 1 / screenScale

    x = (eventX - $('.content').offset().left) / screenScale
    y = (eventY - $('.content').offset().top) / screenScale

    elementForm =
      "<article class='add-element'>
        <div class='card text comment'>
          <p>
            <textarea name='content' class='new' placeholder='Paste a link or an image'></textarea>
          </p>
          <p>
            <form enctype='multipart/form-data' class='direct-upload'>
              <input type='hidden' name='key'>
              <input type='hidden' name='AWSAccessKeyId' value='AKIAJQ7VP2SMGLIV5JQA'>
              <input type='hidden' name='acl' value='public-read'>
              <input type='hidden' name='policy'>
              <input type='hidden' name='signature'>
              <input type='hidden' name='success_action_status' value='201'>
              <input type='hidden' name='Content-Type'>" +
              (if createdByPaste then "" else "<input type='file' class='file-input' name='file'>") +
            "</form>
          </p>
        </div>
      </article>"

    # add the new element form
    # if not createdByPaste
    $('.content').append elementForm
    $('.add-element').on 'click', (event) -> event.stopPropagation()
      .css(
        scale: scale
        "transform-origin": "top left"
        'z-index': "#{window.maxZ + 1}"
        top: "#{y}px"
        left: "#{x}px")

    # allow file uploads
    # if not createdByPaste
    #   $('.direct-upload').fileupload fileuploadOptions x, y, null, screenScale

    $('textarea.new').focus().autoGrow()
      .on 'keyup', (event) ->
        # on enter (not shift + enter), submit either website or text
        if (event.keyCode is 13 and not event.shiftKey)# or createdByPaste
          if isWebsite $(this).val()
            url = encodeURIComponent $(this).val().slice(0, -1)
            emitElement x, y, scale, url, 'website'

          else # this is text
            content = $('textarea[name=content]').val().slice(0, -1)
            emitElement x, y, scale, content, 'text'