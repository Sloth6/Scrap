logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

card =
  place: (animate = true) ->
    border = $(window).width() / 6

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
      x = left_start - ((logistic(percent)-0.5)*2 * border)
    
    percentAcross = x / $(window).width()
    cardScale = 1 - ((1 - percentAcross) * .1)
    
    if animate # opening or closing
      $(@).velocity {
        properties:
          translateZ: 0
          translateX: [x, xTransform($(@))]
          # scale: cardScale
          # translateY: Math.random() * 200 + 50
          # rotateZ: (Math.random() * 8) + (Math.random() * -8)
          # opacity: animate.opacity
        options:
          duration: openCollectionDuration
          queue: false
          easing: [500, 100]
      }
    else # scrolling
      # $(@).velocity {
      #   properties:
      #     # translateZ: 0
      #     translateX: x
      #     # scale: cardScale
      #   options:
      #     queue: false 
      #     duration: 0
      # }
      $(@).css { x }
