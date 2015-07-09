totalDelta = {x: 0, y: 0}
click = {}
startPosition = {}
longText = 50 #number of characters

$ ->
  window.socket = io.connect()
  window.elementForm = $('.addElementForm').remove()
  window.mouse = { x: 0, y: 0 }

  bindVideoControls $('article.video')
  bindFileControls $('article.file')
  bindSoundCloudControls $('article.soundcloud')

#   window.oncontextmenu = () -> false

  $('.menu').mousedown (e) -> e.stopPropagation()
  $('.menu').mouseup (e) -> e.stopPropagation()

  $(window).on 'dragover', (event) ->
    event = event.originalEvent
    mouse.x = event.clientX
    mouse.y = event.clientY

  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

  $(window).mousedown (event) ->
    $(@).data 'lastX', event.clientX
    $(@).data 'lastY', event.clientY

  $(window).mouseup (event) ->
    return unless event.target is document.body
    return if $(@).data('lastX') != event.clientX
    return if $(@).data('lastY') != event.clientY

    if $('.editing').length
      stopEditing()

    else if $('.addElementForm').length
      $('.addElementForm').remove()

    else
      addElement event, false

  removeDraggingClass = (event) ->
    $(event.target).removeClass 'dragging'
    $(this).off 'mousemove', onScreenDrag

  $(window).on 'mousedown', (event) ->
    window.prev =
      x: event.clientX
      y: event.clientY
    return unless event.target is document.body
    $(this).off 'mouseup', removeDraggingClass
    $(window).on 'mousemove', onScreenDrag
    $(window).on 'mouseup', removeDraggingClass


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

  # Initialize file uploads by dragging
  if $('.drag-upload').fileupload
    $('.drag-upload').fileupload fileuploadOptions(true)
