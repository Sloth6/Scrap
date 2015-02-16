totalDelta =
  x: 0
  y: 0

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
  spaceScale = $('.content').css 'scale'
  controlScale = control.attr('data-scale')
  newControlScale = (1 / spaceScale) * controlScale
  control.css         'transform', 'scale(' + newControlScale + ')'
  control.css '-webkit-transform', 'scale(' + newControlScale + ')'

click = {}

startPosition = {}

$ ->
  $('.menu').mousedown (e) ->
    e.stopPropagation()
  $('.menu').mouseup (e) ->
    e.stopPropagation()