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

$ ->
  $('.menu').mousedown (e) ->
    e.stopPropagation()
  $('.menu').mouseup (e) ->
    e.stopPropagation()