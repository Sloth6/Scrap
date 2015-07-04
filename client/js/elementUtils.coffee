matrixToArray = (str) -> str.match(/(-?[0-9\.]+)/g)

elementScale = (element) ->
  matrix = element.css('transform') or element.css('-webkit-transform')
  array = matrixToArray(matrix)
  return array[0] if array?.length
  console.log 'invalid elemnt passed to elementScale', element, console.trace()



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

# Get all comments attached to an element in zindex order.
getComments = (elem) ->
  if elem.data('children')?.length
    elem.data('children').map((id) -> $('#'+id)).sort (a, b) ->
      parseInt(a.css('zIndex')) - parseInt(b.css('zIndex'))
  else
    []

bringToTop = (elem) ->
  window.maxZ += 1
  elem.css 'z-index', window.maxZ