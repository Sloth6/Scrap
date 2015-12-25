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

calculateX = ($content, margin) ->
  $collection = contentModel.getCollection $content
  isForm = $content.hasClass('addArticleForm') or $content.hasClass('addProjectForm')
  border = sliderBorder
  x = $content.data('scrollOffset') - $(window).scrollLeft()# + margin
  maxX = $(window).width() - contentModel.getSize($content)
  right_start = $(window).width() - border
  left_min = - contentModel.getSize($content) + edgeWidth
  left_start = left_min + border
#   if $collection.hasClass 'root'
#     left_start = $(window).width() / 2
  
  if isForm
#     console.log 'form at edge'
    border = 132
# is piling up on right
  if x > right_start
    percent = (x - right_start) / border
    x = right_start + (logisticFunction(percent)-0.5)*2 * border

  if isForm
    $content.addClass 'onEdge'
    # is piling up on left
    
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x = left_start - ((logisticFunction(percent)-0.5)*2 * border)
    
  else
    if isForm
      $content.removeClass 'onEdge'
    
    
  #   if $content.hasClass('cover')# and not $collection.hasClass('root')
  #     console.log 'cover',  $collection.attr 'class'
  
  # Prevent stack from shifting to right when growing
  # x -= .0001825 * rawX
  x

calculateY = ($content, margin, jumble, multiple) ->
  if jumble?
    jumble.translateY * multiple
  else 
    0

calculateScale = ($content, margin, jumble, multiple) ->
  rawX = $content.data('scrollOffset') - $(window).scrollLeft() + margin
  if rawX < sliderBorder
    1 + (rawX * .00001)
  else
    1

calculateRotateZ = ($content, margin, jumble, multiple) ->
  if $content.hasClass('addArticleForm') or $content.hasClass('addProjectForm')
    return 0
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
  draw: ($content,  options) ->
    animate = options.animate or false
    margin = 0#$content.data('margin') or 0
    jumble = $content.data 'jumble'
    isPack = $content.hasClass('cover') or $content.hasClass('pack')
    
    translateX = calculateX $content, margin
    
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
      # $content.css "-webkit-transform", "translate3d(#{translateX}px, #{translateY}px, 0px) rotateZ(#{rotateZ})"
      velocityParams.options = { duration: 1 }

    # Only call animate if change is noticeable.
    if Math.abs(translateX - oldX) > 1
      $content.velocity velocityParams
