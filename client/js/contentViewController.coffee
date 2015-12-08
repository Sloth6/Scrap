calculatePercentToBorder = (x, e, border) ->
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

calculateX = ($content, scroll, percentToBorder) ->
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

calculateY = ($content, jumble, percentToBorder) ->
  jumble.translateY * percentToBorder

calculateScale = ($content, jumble, percentToBorder) ->
  rawX = $content.data('scrollOffset') - $(window).scrollLeft() + margin
  if rawX < sliderBorder
    1 + (rawX * .00001)
  else
    1

calculateRotateZ = ($content, jumble, percentToBorder) ->
  rotateZ = jumble.rotateZ * percentToBorder
  rotateZ

# If slider is at edge
# if translateX + contentModel.getSize($content) < edgeWidth or translateX > $(window).width() - edgeWidth
#   $content.addClass 'onEdge'
#   # Make edge of card visible on open collections
#   if $content.hasClass 'cover'
#     $content.addClass 'peek' if $content.hasClass 'open'
#   if $content.hasClass 'addArticleForm'
#     #If focused or focused with empty field
#     if (!$content.hasClass('focus')) or ($content.find('textarea').val() == '')
#       $content.addClass 'peek'
#       $content.find('textarea').blur()
#       $content.find('.card').removeClass 'editing'
#       $content.removeClass 'slideInFromSide'
    
# Not at edge
# else
#   $content.removeClass 'onEdge'
#   if $content.hasClass 'cover' or $content.hasClass 'addArticleForm' 
#     $content.removeClass 'peek'
#   if $content.hasClass 'addArticleForm' 
#     $content.removeClass 'peek'

# percentFromCenter = percentToBorder((translateX), $content, $(window).width()/2)


# On open/close or load

window.contentViewController =
  draw: ($content, scroll,  options) ->
    animate = options.animate or false
    jumble = $content.data('jumble')
    percentToBorder = calculatePercentToBorder(xTransform($content), $content, sliderBorder)
    
    translateX = calculateX $content, scroll, percentToBorder
    oldX       = xTransform $content, jumble, percentToBorder
    translateY = calculateY $content, jumble, percentToBorder
    scale      = calculateScale $content, jumble, percentToBorder
    rotateZ    = calculateRotateZ $content, jumble, percentToBorder

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

