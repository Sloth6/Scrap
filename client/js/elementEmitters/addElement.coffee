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
  # add the new element form if not createdByCntrl
  elementForm.
    css
      scale: scale
      "transform-origin": "top left"
      'z-index': "#{window.maxZ + 1}"
      top: "#{y}px"
      left: "#{x}px"
    .appendTo $('.content')
    .show()
    .on 'click', (event) -> event.stopPropagation()

  floatingMenuController.reset elementForm
  floatingMenuController.init elementForm
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
