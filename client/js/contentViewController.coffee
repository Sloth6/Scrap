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

calculateX = ($content, margin, scroll) ->
  border = sliderBorder
  x = $content.data('scrollOffset') - $(window).scrollLeft()# + margin
  maxX = ($(window).width() * 2) - contentModel.getSize($content)
  right_start = ($(window).width() * 2) - border
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

calculateY = ($content, margin, jumble, multiple) ->
  if jumble?
    jumble.translateY * multiple
  else 
    0

calculateScale = ($content, margin, jumble, multiple) ->
  scale = 1 # jumble.scale
  rawX = $content.data('scrollOffset') - $(window).scrollLeft() + margin
  if rawX < sliderBorder
    scale + (rawX * .00001)
  else
    scale

calculateRotateZ = ($content, margin, jumble, multiple) ->
  return 0 unless jumble?
  jumble.rotateZ * multiple

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
    margin = $content.data('margin')
    jumble = $content.data 'jumble'
    isPack = $content.hasClass('cover') or $content.hasClass('pack')
    
    translateX = calculateX       $content, margin, scroll
    
    percentToBorder = calculatePercentToBorder(translateX, $content, sliderBorder)
    multiple = if isPack then 1 else percentToBorder
        
    oldX       = xTransform $content
    translateY = calculateY       $content, margin, jumble, multiple
    scale      = calculateScale   $content, margin, jumble, multiple
    rotateZ    = calculateRotateZ $content, margin, jumble, percentToBorder

    velocityParams = 
      properties:
        translateZ: 0
        translateX: [translateX, oldX]
        translateY: translateY
        rotateZ: rotateZ
        scale: scale

    # Velocity cannot actually have 0 duration
    if !animate
      velocityParams.options = { duration: 1 }

    # Only call animate if change is noticeable.
    if Math.abs(translateX - oldX) > 1
      $content.velocity velocityParams

