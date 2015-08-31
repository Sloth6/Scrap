$ ->
  bindCardHover()

bindCardHover = () ->
  $cards = $('.card')
  $cards.mouseenter( () ->
    $(@).addClass 'hover'
  ).mouseleave( () ->
    $(@).removeClass 'hover'
  )