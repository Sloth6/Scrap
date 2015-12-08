# $ ->
#   bindCardHover()

# bindCardHover = () ->
#   $cardContainers = $('header.cover, .collection article')
#   $cardContainers.mouseenter( () ->
#     $(@).not('.onEdge').find('.cardHover').addClass 'hover'
#   ).mouseleave( () ->
#     $(@).not('.onEdge').find('.cardHover').removeClass 'hover'
#   )
