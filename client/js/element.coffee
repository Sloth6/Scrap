logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

element_place = () ->
  element = $(@)
  border = 300

  return if element.hasClass('dragging')
  offset = element.data 'scroll_offset'
  collection_scroll = element.parent().parent().data 'scroll_position'
  maxX = ($(window).width()  / scale )- element.width()

  x = offset + collection_scroll + margin

  start = ($(window).width() - border)

  left_min = -element.width()
  left_start = left_min + border

  if x > start
    percent = (x - start) / border
    x = start + (logistic(percent)-0.5)*2 * border
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x =  left_start - ((logistic(percent)-0.5)*2 * border)
    
  element.css { x, y:0 }

element_move = (x, delta = false) ->
  element = $(@)
  offset = element.data 'scroll_offset'
  element.data 'scroll_offset', offset + x
  element_place.call @
