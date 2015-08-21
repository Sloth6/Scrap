logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

card =
  place: () ->
    border = $(window).width() / 6

    # return if card.hasClass('dragging')
    offset = $(@).data 'scroll_offset'
    maxX = ($(window).width())- $(@).width()

    x = offset - $(window).scrollLeft() + margin

    right_start = ($(window).width() - border)
    left_min = -$(@).width()
    left_start = left_min + border

    if x > right_start
      percent = (x - right_start) / border
      x = right_start + (logistic(percent)-0.5)*2 * border
    
    else if x < left_start
      percent = 1 - ((x - left_min)/ border)
      x =  left_start - ((logistic(percent)-0.5)*2 * border)
    
    $(@).css { x, y: 0 }