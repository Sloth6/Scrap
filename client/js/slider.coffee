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

percentToBorder = (x, e, border) -> 
  maxX = $(window).width() - e.width()
  right_start = $(window).width() - border
  left_min = - e.width() + edgeWidth
  left_start = left_min + border

  if x > right_start
    percent = (x - right_start) / border
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
  else
    percent = 0
  percent
  

sliderJumble = () ->
  $(@).data
    'translateY': (Math.random()-.5) * 50# + 50
    'rotateZ': Math.random() * 4 + (Math.random() * -4)
    'scale': 1

slidingPlace = (animate = true) ->
# Recalculated on scroll
  rawX = $(@).data('scroll_offset') - $(window).scrollLeft() + margin
  translateX = getTranslateX rawX, $(@)
# Prevent stack from shifting to right when growing
  translateX += .0025 * rawX
  
  
  percentFromCenter = percentToBorder((translateX), $(@), $(window).width()/2)
  percentFromBorder = percentToBorder((translateX), $(@), sliderBorder())
  translateY = $(@).data('translateY') * percentFromCenter

  scale = 1
  if rawX < sliderBorder()
    scale = 1 - (rawX * .00001)
  rotateZ = $(@).data('rotateZ') * percentFromCenter
# On open/close or load
  animateOptions =
    properties:
      translateZ: 0
      translateX: [translateX, xTransform($(@))]
      scale: scale
      translateY: translateY
      rotateZ: $(@).data('rotateZ') * percentFromBorder
    options:
      duration: openCollectionDuration
      queue: false
      easing: [500, 100]

# On open/close or load
  if animate
    $(@).velocity animateOptions
    
# On Scroll
  else
    options = {x: translateX}
    options.y = translateY if translateY?
    if $(@).data('rotateZ')
        options.rotate3d = "0,0,1,#{rotateZ}deg" 
    if $(@).data('scale')
        options.scale = scale
    $(@).css options