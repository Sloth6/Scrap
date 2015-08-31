logistic = (x) -> 1/(1 + Math.pow(Math.E, -x))

getTranslateX = (x, e) ->  
  border = sliderBorder()
  myEdgeWidth = if e.hasClass('cover') then edgeWidth/2 else edgeWidth

  maxX = $(window).width() - e.width()
  right_start = $(window).width() - border
  left_min = - e.width() + myEdgeWidth
  left_start = left_min + border

  if x > right_start
    percent = (x - right_start) / border
    x = right_start + (logistic(percent)-0.5)*2 * border
  
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x = left_start - ((logistic(percent)-0.5)*2 * border)
  x

percentToBorder = (x, e, border) ->
  myEdgeWidth = if e.hasClass('cover') then edgeWidth/2 else edgeWidth

  maxX = $(window).width() - e.width()
  right_start = $(window).width() - border
  left_min = - e.width() + myEdgeWidth
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

sliderInit = (elems) ->
  bindCardHover()
  showAddElementForm()
  elems.each sliderJumble
  makeDraggable elems
  elems.mouseover( () ->
    return unless $(@).hasClass('sliding')
    x = xTransform($(@))
    return if x < edgeWidth or (x > $(window).width - edgeWidth)
    $(@).data 'oldZIndex', $(@).css('zIndex')
    $(@).css 'zIndex', collectionChildren.call($('.slidingContainer')).length + 1
  ).mouseout () ->
    $(@).data('oldZIndex') and $(@).css 'zIndex', $(@).data('oldZIndex')


slidingPlace = (animate = true) ->
  # Recalculated on scroll
  rawX = $(@).data('scroll_offset') - $(window).scrollLeft() + margin
  translateX = getTranslateX rawX, $(@)
  
  # Prevent stack from shifting to right when growing
  translateX += .001825 * rawX
  
  # If slider is at edge
  if translateX + $(@).width() < edgeWidth or translateX > $(window).width() - edgeWidth
     $(@).addClass 'onEdge'
     $(@).find('.card').removeClass 'cardHover'
     # Make edge of card visible on open collections
     if $(@).hasClass 'cover'
       $(@).addClass 'peek' if $(@).hasClass 'open'
     if $(@).hasClass 'addElementForm' 
       $(@).addClass 'peek'
  # Not at edge
  else
    $(@).removeClass 'onEdge'
    $(@).find('.card').addClass 'cardHover'
    if $(@).hasClass 'cover' or $(@).hasClass 'addElementForm' 
      $(@).removeClass 'peek' if $(@).hasClass 'open'
    if $(@).hasClass 'addElementForm' 
      $(@).removeClass 'peek' if $(@).hasClass 'open'
  
  percentFromCenter = percentToBorder((translateX), $(@), $(window).width()/2)
  percentFromBorder = percentToBorder((translateX), $(@), sliderBorder())
  translateY = $(@).data('translateY') * percentFromCenter

  scale = 1
  if rawX < sliderBorder()
    scale = 1 - (rawX * .00001)
  rotateZ = $(@).data('rotateZ') * percentFromCenter
  
  # On open/close or load
  if animate
    animateOptions =
      properties:
        translateZ: 0
        translateX: [translateX, xTransform($(@))]
        scale: scale
        translateY: translateY
        rotateZ: $(@).data('rotateZ') * percentFromBorder

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