logistic = (x) -> 1/(1 + Math.pow(Math.E, -x))

getTranslateX = (x, e) ->  
  border = sliderBorder()
  maxX = $(window).width() - e.width()
  right_start = $(window).width() - border
  left_min = - e.width() + edgeWidth
  left_start = left_min + border

  if x > right_start
    percent = (x - right_start) / border
    x = right_start + (logistic(percent)-0.5)*2 * border
  
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x = left_start - ((logistic(percent)-0.5)*2 * border)
  x

sliderJumble = () ->
  $(@).data
    'translateY': Math.random() * 100 + 50
    'rotateZ': Math.random() * 4 + (Math.random() * -4)

slidingPlace = (animate = true) ->
  rawX = $(@).data('scroll_offset') - $(window).scrollLeft() + margin
  translateX = getTranslateX rawX, $(@)

  percentAcross = translateX / $(window).width()
  # cardScale = 1 - ((1 - percentAcross) * .1)
  
  animateOptions =
    properties:
      translateZ: 0
      translateX: [translateX, xTransform($(@))]
      # scale: cardScale
      translateY: $(@).data('translateY')
      rotateZ: $(@).data('rotateZ')
    options:
      duration: openCollectionDuration
      queue: false
      easing: [500, 100]

  # opening or closing
  if animate
    $(@).velocity animateOptions
  else
    options = {x: translateX}
    options.y = $(@).data('translateY') if $(@).data('translateY') 
    options.rotate3d = "0,0,1,#{$(@).data('rotateZ')}deg" if $(@).data('rotateZ')
    $(@).css options
      

