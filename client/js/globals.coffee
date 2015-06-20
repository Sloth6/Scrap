totalDelta =
  x: 0
  y: 0

click = {}

startPosition = {}

longText = 50 #number of characters

matrixToArray = (str) -> str.match(/(-?[0-9\.]+)/g)

elementScale = (element) ->
  matrix = element.css('transform') or element.css('-webkit-transform')
  matrixToArray(matrix)[0]

elementPosition = (element) ->
  x = parseInt element.css('left')
  y = parseInt element.css('top')
  {x, y}

dimension = (elem) ->
  scale = $('.content').css('scale')
  elemScale = elementScale elem
  w = parseInt(elem.css('width')) * elemScale
  h = parseInt(elem.css('height')) * elemScale
  { w, h }
  
scaleControls = (control) ->
  spaceScale        = $('.content').css 'scale'
  controlScale      = control.attr('data-scale')
  newControlScale   = ((1 / spaceScale) * controlScale) * .75
  control.css         'transform', 'scale3d(' + newControlScale + ',' + newControlScale + ', 1.0)'
  control.css '-webkit-transform', 'scale3d(' + newControlScale + ',' + newControlScale + ', 1.0)'

# Get all comments attached to an element in zindex order.
getComments = (elem) ->
  if elem.data('children')?.length
    elem.data('children').map((id) -> $('#'+id)).sort (a, b) ->
      parseInt(a.css('zIndex')) - parseInt(b.css('zIndex'))
  else
    []

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

$ ->
  window.socket = io.connect()
  window.elementForm = $('.addElementForm').remove()
  window.mouse = { x: 0, y: 0 }

  bindVideoControls $('article.video')
  bindFileControls $('article.file')

  window.oncontextmenu = () -> false

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
    if $('.addElementForm').length
      $('.addElementForm').remove()
    else
      addElement event, false

  removeDraggingClass = (event) ->
    $(event.target).removeClass 'dragging'
    $(this).off 'mousemove', onScreenDrag

  $(window).on 'mousedown', (event) ->
    return unless event.target is document.body
    window.prev =
      x: event.clientX
      y: event.clientY

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
