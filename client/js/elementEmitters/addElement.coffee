$ ->

  socket = io.connect()
  mouse = { x: 0, y: 0 }
  window.ignoreMouseup = false

  # On document so that it doesn't get messed up by screenDrag
  $(document).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

  $(window).mousedown (event) ->
    window.dontAddNext = $('.add-element').length
    $('.add-element').remove()

  # The options for s3-streamed file uploads, used later
  fileuploadOptions = (x, y, contentType, scale) ->
    multipart = false
    url: "http://scrapimagesteamnap.s3.amazonaws.com" # Grabs form's action src
    type: 'POST'
    autoUpload: true
    dataType: 'xml' # S3's XML response
    add: (event, data) ->      
      $.ajax "/sign_s3", {
        type: 'GET'
        dataType: 'json'
        data: {title: data.files[0].name} # Send filename to /signed for the signed response 
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

  isImage = (url) ->
    url.match(/\.(jpeg|jpg|gif|png)$/)?

  isWebsite = (url) ->
    expression = /[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi
    !!url.match expression

  # adds caption and element to DOM
  addCaption = (x, y, scale, contentType, content, innerHTML) ->
    $('.add-element').remove()
    captionForm = 
      "<div class='card text comment'>
        <textarea name='comment' placeholder='Add a comment'></textarea>
      </div>
      <div class='ui-resizable-handle ui-resizable-se ui-icon ui-icon-grip-diagonal-se'>
      </div>"

    element =
      "<article class='#{contentType} add-#{contentType}'>
        <a class='delete' href='#'></a>
        <div class='card #{contentType}'>
          #{innerHTML()}
        </div>
        #{captionForm}
      </article>"

    $('.content').append element
    $(".add-#{contentType}").css(
      scale: scale
      "transform-origin": "top left"
      'z-index': window.maxZ
      top: "#{y}px"
      left: "#{x}px")
    $(this).remove()
    $('textarea').focus()
      .on 'blur', (event) -> emitElement x, y, scale, content, contentType
      .on 'keyup', (event) -> emitElement x, y, scale, content, contentType if event.keyCode is 13 and not event.shiftKey

  # on double-click, append new element form, then process the new element if one is submitted
  $('.container').mouseup (event) ->
    if window.dontAddNext
      window.dontAddNext = false
      return
    boxUp = true
    screenScale = $('.content').css('scale') 
    elementScale = 1 / screenScale
    x = (event.clientX - $('.content').offset().left) / screenScale
    y = (event.clientY - $('.content').offset().top) / screenScale
    # console.log(screenScale)
    elementForm =
      "<article class='add-element'>
        <div class='card text comment'>
          <p>
            <textarea name='content' placeholder='Paste a link or an image'></textarea>
          </p>
          <p>
            <form enctype='multipart/form-data' class='direct-upload'>
              <input type='hidden' name='key'>
              <input type='hidden' name='AWSAccessKeyId' value='AKIAJQ7VP2SMGLIV5JQA'>
              <input type='hidden' name='acl' value='public-read'>
              <input type='hidden' name='policy'>
              <input type='hidden' name='signature'>
              <input type='hidden' name='success_action_status' value='201'>
              <input type='hidden' name='Content-Type'>
              <span class='fileInputWrapper'><input type='file' class='file-input' name='file'></span>
            </form>
          </p>
        </div>
      </article>"

    # add the new element form
    $('.content').append elementForm
    $('.add-element').on 'click', (event) -> event.stopPropagation()
      .css(
        scale: elementScale
        "transform-origin": "top left"
        'z-index': "#{window.maxZ + 1}"
        top: "#{y}px"
        left: "#{x}px")

    # allow file uploads
    $('.direct-upload').fileupload fileuploadOptions x, y, null, screenScale

    $('textarea').focus().autoGrow()
      .on 'keyup', (event) ->

        # on paste of image, submit without hitting enter
        if isImage $(this).val() 
          content = $(this).val()
          innerHTML = (content) -> "<img src='#{content}'>"
          addCaption x, y, elementScale, 'image', content, innerHTML

        # on enter (not shift + enter), submit either website or text
        else if event.keyCode is 13 and not event.shiftKey
          if isWebsite $(this).val()
            url = encodeURIComponent $(this).val().slice(0, -1)
            emitElement x, y, elementScale, url, 'website'

          else # this is text
            content = $('textarea[name=content]').val().slice(0, -1)
            emitElement x, y, elementScale, content, 'text'
