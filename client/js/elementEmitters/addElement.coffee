locations = {}
getUploadLocation = (names, onDrag) ->
  screenScale = $('.content').css 'scale'
  if onDrag
    x = (mouse.x - $('.content').offset().left) / screenScale
    y = (mouse.y - $('.content').offset().top) / screenScale
  else
    { x, y } = elementPosition $('.addElementForm')

  for name in names
    locations[name] = {x, y}

fileuploadOptions = (onDrag) ->
  multipart = false
  url: "http://scrapimagesteamnap.s3.amazonaws.com" # Grabs form's action src
  type: 'POST'
  autoUpload: true
  dataType: 'xml' # S3's XML response
  add: (event, add_data) ->
    getUploadLocation (file.name for file in add_data.originalFiles), onDrag
    $.ajax "/sign_s3", {
      type: 'GET'
      dataType: 'json'
      data:# Send filename to /signed for the signed response 
        title: add_data.files[0].name
        type: add_data.files[0].type
        spaceKey: spaceKey
      async: false
      success: (success_data) ->
        file_name = success_data.key.split('/').pop()
        createLoadingElement locations[file_name], file_name.split('.')[0]
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
    console.log 'fail', e, data

  success: (data) ->

    # Find location value from XML response
    content = decodeURIComponent $(data).find('Location').text()
    file_name = content.split('/').pop()
    { x, y } = locations[file_name]# getUploadLocation onDrag
    emitElement x, y, content

$ ->
  window.elementForm = $('.addElementForm').remove()
  window.mouse = { x: 0, y: 0 }
  $(window).on 'dragover', (event) ->
    event = event.originalEvent
    mouse.x = event.clientX
    mouse.y = event.clientY

  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

  window.oncontextmenu = () -> false

  $(window).mousedown (event) ->
    if event.which is 3 #right mouse
      event.preventDefault()
      $('.addElementForm').remove()
      addElement event, false
  
  $(window).on 'click', (event) ->
    $('.addElementForm').remove()
  
  $(window).bind 'paste', (event) ->
    # ensure the add element panel is not already open.
    if $('.addElementForm').length is 0
      addElement event, true
    else
      setTimeout (() ->
        if $('input.urlInput').val() != ''
          { x, y } = elementPosition $('.addElementForm')
          emitElement x, y, $('input.urlInput').val()), 20

  
  # $(window).keypress (event) -> 
  #   if $('.addElementForm').length is 0
  #     addElement event, false

  # The options for s3-streamed file uploads, used later


  # Initialize file uploads by dragging
  if $('.drag-upload').fileupload
    $('.drag-upload').fileupload fileuploadOptions(true)

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

  $('.addElementForm').remove()

addElement = (event, createdByCntrl) ->
  eventX = event.clientX || mouse.x
  eventY = event.clientY || mouse.y
  scale = 1 / $('.content').css('scale')
  x = (eventX - $('.content').offset().left) * scale
  y = (eventY - $('.content').offset().top) * scale

  input = elementForm.find('.textInput')
  input.off 'keyup'
  elementForm.find('.textInput,.urlInput').val('')
  # add the new element form if not createdByCntrl
  elementForm.
    css
      scale: scale
      "transform-origin": "top left"
      'z-index': "#{window.maxZ + 1}"
      top: "#{y}px"
      left: "#{x}px"
    .appendTo $('.content')
    .on 'click', (event) -> event.stopPropagation()
  # allow file uploads
  if not createdByCntrl
    $('.direct-upload').fileupload fileuploadOptions(false)

  input.focus().autoGrow()
  
  if createdByCntrl
    setTimeout(() ->
      content = input.val()
      emitElement x, y, content
    , 20)
  else 
    input.on 'keyup', (event) ->
      # on enter (not shift + enter)
      if event.keyCode is 13 and not event.shiftKey
        content = input.val()
        emitElement x, y, content
