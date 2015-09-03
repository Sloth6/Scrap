$ ->
  bindCardHover()

bindCardHover = () ->
  $cardContainers = $('header.cover, .collection article')
  $cardContainers.mouseenter( () ->
    $(@).find('.card').addClass 'hover'
  ).mouseleave( () ->
    $(@).find('.card').removeClass 'hover'
  )
