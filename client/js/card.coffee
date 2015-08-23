logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

card =
  place: (animateOptions = null) ->
    # console.log @
    border = $(window).width() / 4

    # return if card.hasClass('dragging')
    offset = $(@).data 'scroll_offset'
    maxX = ($(window).width())- $(@).width()

    x = offset - $(window).scrollLeft() + margin
    right_start = $(window).width() - border
    left_min = -$(@).width()
    left_start = left_min + border

    if x > right_start
      percent = (x - right_start) / border
      x = right_start + (logistic(percent)-0.5)*2 * border
    
    else if x < left_start
      percent = 1 - ((x - left_min)/ border)
      x =  left_start - ((logistic(percent)-0.5)*2 * border)
    
    # console.log animateOptions
    if animateOptions
      $(@).velocity {
        properties:
          translateX: x
          # opacity: animateOptions.opacity
        options:
          duration: 1000
          queue: false
          easing: [500, 100]
          complete: animateOptions.complete or (() ->)
      }
    else
      $(@).velocity {
        properties:
          translateX: x
        options:
          queue: false 
          duration: 0
      }
      # $(@).css { x, y: 0 }