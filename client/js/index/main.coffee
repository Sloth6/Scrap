scale = 0.5
margin = -0.5

logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

element_place = () ->
  element = $(@)
  border = 300

  return if element.hasClass('dragging')
  offset = element.data 'scroll_offset'
  collection_scroll = element.parent().data 'scroll_position'
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
  # x = Math.max x, 0
  # x = Math.min x, maxX

  element.css { x, y:0 }

collection_realign_elements = () ->
  collection = $(@)
  lastX = 0
  maxX = -Infinity
  zIndex = collection.children().length
  collection.children().each () ->
    if not $(@).hasClass 'dragging'
      $(@).data 'scroll_offset', lastX
      $(@).css {zIndex: zIndex--}
      element_place.call @
      lastX += $(@).width() + margin
      maxX = lastX

  $(@).data { maxX }

collection_init = () ->
  $(@).data 'scroll_position', 0
  collection_realign_elements.call @

$ ->
  $('.collection').each collection_init