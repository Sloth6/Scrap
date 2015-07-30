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

  right_start = ($(window).width() - border) / scale

  left_min = -element.width()
  left_start = left_min + border

  if x > right_start
    percent = (x - right_start) / border
    x = right_start + (logistic(percent)-0.5)*2 * border
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x =  left_start - ((logistic(percent)-0.5)*2 * border)
  
  # if animate
  #   element.animate { x, y:0 }, 200
  # else  
  element.css { x, y:0 }

element_move = (x, animate = false) ->
  element = $(@)
  offset = element.data 'scroll_offset'
  element.data 'scroll_offset', offset + x
  element_place.call @, animate
