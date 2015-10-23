logistic = (x) -> 1/(1 + Math.pow(Math.E, -x))

getTranslateX = (x, e) ->  
  border = sliderBorder()

  maxX = $(window).width() - sliderWidth(e)
  right_start = $(window).width() - border
  left_min = - sliderWidth(e) + edgeWidth
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

sliderInit = (elems) ->
  bindCardHover()
  elems.css y: marginTop
  elems.each sliderJumble
  elems.addClass('sliding')
  makeDraggable elems
  makeDeletable elems
  # elems.find('.transforms').css 'transform-origin': 'center center'
  # elems.find('.transforms').css '-webkit-transform-origin': 'center center'
  elems.each () ->
    switch $(@).data('contenttype')
      when 'text'
        makeModifiable $(@)
      when 'video'
        bindVideoControls $(@)
      when 'file'
        bindFileControls $(@)
      when 'soundcloud'
        bindSoundCloudControls $(@)
      when 'youtube'
        bindYoutubeControls $(@)
      when 'cover'
        coverInit $(@)
      when 'addElementForm'
        addElementController.init $(@)
      when 'addProjectForm'
        addProjectController.init $(@)

  elems.mouseover( () ->
    return unless $(@).hasClass('sliding')
    x = xTransform($(@))
    return if x < edgeWidth or (x > $(window).width - edgeWidth)
    return if $(@).hasClass 'dragging'
    $(@).data 'oldZIndex', $(@).css('zIndex')
    $(@).css 'zIndex', $.topZIndex('article')
  ).mouseout () ->
    return if $(@).hasClass 'dragging'
    $(@).data('oldZIndex') and $(@).css 'zIndex', $(@).data('oldZIndex')

slidingPlace = (animate = true) ->
  # Recalculated on scroll
  rawX = $(@).data('scroll_offset') - $(window).scrollLeft() + margin
  translateX = getTranslateX rawX, $(@)
  
  # Prevent stack from shifting to right when growing
  translateX -= .0001825 * rawX
  # If slider is at edge
  if translateX + sliderWidth($(@)) < edgeWidth or translateX > $(window).width() - edgeWidth
    $(@).addClass 'onEdge'
    # Make edge of card visible on open collections
    if $(@).hasClass 'cover'
      $(@).addClass 'peek' if $(@).hasClass 'open'
    if $(@).hasClass 'addElementForm'
      #If focused or focused with empty field
      if (!$(@).hasClass('focus')) or ($(@).find('textarea').val() == '')
        $(@).addClass 'peek'
        $(@).find('textarea').blur()
        $(@).find('.card').removeClass 'editing'
        $(@).removeClass 'slideInFromSide'
      
  # Not at edge
  else
    $(@).removeClass 'onEdge'
    if $(@).hasClass 'cover' or $(@).hasClass 'addElementForm' 
      $(@).removeClass 'peek'
    if $(@).hasClass 'addElementForm' 
      $(@).removeClass 'peek'
  
  percentFromCenter = percentToBorder((translateX), $(@), $(window).width()/2)
  percentFromBorder = percentToBorder((translateX), $(@), sliderBorder())

  if ($(@).hasClass('cover') and $(@).hasClass('open')) or $(@).hasClass('addElementForm')
    translateY = 0
  else
    translateY = ($(@).data('translateY') * percentFromBorder)


  scale = 1
  if rawX < sliderBorder()
    scale = 1 + (rawX * .00001)
  rotateZ = $(@).data('rotateZ') * percentFromBorder
  
  # On open/close or load
  if animate
    oldX = xTransform($(@))
    if Math.abs(translateX - oldX) > 1
      animateOptions =
        properties:
          translateZ: 0
          translateX: [translateX, oldX]
          translateY: [marginTop, marginTop]
          scale: scale
          # translateY: [translateY, yTransform($(@))]
          rotateZ: $(@).data('rotateZ') * percentFromBorder

      $(@).velocity animateOptions

  # On Scroll
  else
    options = { x: translateX }
    # options.y = translateY if translateY?
    options.y = marginTop
    if $(@).data('rotateZ')
        options.rotate3d = "0,0,1,#{rotateZ}deg" 
    if $(@).data('scale')
        options.scale = scale
    $(@).css options

sliderWidth = (elem) ->
  elem.data('width') or elem.find('.card').width()