logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

element_collection = () ->
  $(@).parent().parent()



element_move = (x, animate = false) ->
  element = $(@)
  offset = element.data 'scroll_offset'
  element.data 'scroll_offset', offset + x
  element_place.call @, animate
 
$ ->
  $('.element').mouseover( () ->
    return unless mouse.x > 100
    $(@).data 'oldZIndex', $(@).css('zIndex')
    $(@).css 'zIndex', $(@).siblings().length + 1
  ).mouseout () ->
    $(@).data('oldZIndex') and $(@).css 'zIndex', $(@).data('oldZIndex')
