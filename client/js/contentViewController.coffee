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

calculateX = ($content, scroll) ->
  border = sliderBorder
  x = $content.data('scrollOffset') - $(window).scrollLeft() + margin
  maxX = $(window).width() - contentModel.getSize($content)
  right_start = $(window).width() - border
  left_min = - contentModel.getSize($content) + edgeWidth
  left_start = left_min + border

  if x > right_start
    percent = (x - right_start) / border
    x = right_start + (logisticFunction(percent)-0.5)*2 * border
  
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x = left_start - ((logisticFunction(percent)-0.5)*2 * border)
  # Prevent stack from shifting to right when growing
  # x -= .0001825 * rawX
  x

calculateY = ($content) ->
  0

calculateScale = ($content) ->
  rawX = $content.data('scrollOffset') - $(window).scrollLeft() + margin
  if rawX < sliderBorder
    1 + (rawX * .00001)
  else
    1

calculateRotateZ = ($content) ->
  percentFromBorder = percentToBorder(xTransform($content), $content, sliderBorder)
  $content.data('rotateZ') * percentFromBorder

# If slider is at edge
# if translateX + contentModel.getSize($content) < edgeWidth or translateX > $(window).width() - edgeWidth
#   $content.addClass 'onEdge'
#   # Make edge of card visible on open collections
#   if $content.hasClass 'cover'
#     $content.addClass 'peek' if $content.hasClass 'open'
#   if $content.hasClass 'addElementForm'
#     #If focused or focused with empty field
#     if (!$content.hasClass('focus')) or ($content.find('textarea').val() == '')
#       $content.addClass 'peek'
#       $content.find('textarea').blur()
#       $content.find('.card').removeClass 'editing'
#       $content.removeClass 'slideInFromSide'
    
# Not at edge
# else
#   $content.removeClass 'onEdge'
#   if $content.hasClass 'cover' or $content.hasClass 'addElementForm' 
#     $content.removeClass 'peek'
#   if $content.hasClass 'addElementForm' 
#     $content.removeClass 'peek'

# percentFromCenter = percentToBorder((translateX), $content, $(window).width()/2)


# On open/close or load

window.contentViewController =
  draw: ($content, scroll,  options) ->
    animate = options.animate or false

    translateX = calculateX $content, scroll
    oldX       = xTransform $content
    translateY = calculateY $content
    scale      = calculateScale $content
    rotateZ    = calculateRotateZ $content

    velocityParams = 
      properties:
        translateZ: 0
        translateX: [translateX, oldX]
        translateY: translateY
        rotateZ: rotateZ
        scale: scale

    # Velocity cannot actually haae 0 duratiom
    if !animate
      velocityParams.options = { duration: 1 }

    # Only call animate if change is noticable.
    if Math.abs(translateX - oldX) > 1
      $content.velocity velocityParams

  jumble: ($contents) ->
    $contents.each () ->
      $(@).data
        'translateY': (Math.random()-.5) * 50# + 50
        # 'rotateZ': Math.random() * 4 + (Math.random() * -4)
        'scale': 1
