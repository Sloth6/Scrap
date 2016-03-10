window.parallaxModel =
  easing: [20, 10] # TODO: Why is constants.velocity.easing.smooth undefined?
  duration: 500
  canParallax: ($element) ->
    not $element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover') or $element.hasClass('ui-draggable-dragging')
  getTransform: ($element) ->
    $element.find('.transform')
  getLayers: ($element) ->
    $element.find('.parallaxLayer')
  getPercentageAcross: ($element, pointer, scale) ->
    # If article, compensate for global scale
    offsetGlobalScale = if $element.is('article') then 1 / (constants.style.globalScale) else 1
    offsetX = $element.offset().left - $(window).scrollLeft()
    offsetY = $element.offset().top  - $(window).scrollTop()
    progressY = offsetGlobalScale * Math.max(0, Math.min(1, (pointer.y - offsetY) / ($element.height() * scale)))
    progressX = offsetGlobalScale * Math.max(0, Math.min(1, (pointer.x - offsetX) / ($element.width()  * scale)))
    { x: progressX, y: progressY }
  getRotate: ($element, progress) ->
    # TODO: extra fix below
    maxRotateY = 22
    maxRotateX = 22
    rotateX = maxRotateY * (progress.y - .5)
    rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
    { x: rotateX, y: rotateY}

window.parallaxView =
  init: ($element) ->
    $element.addClass 'parallaxHover'
    $element.wrapInner '<span></span>' if $element.is('a')
    perspective = if $element.hasClass('image') or $element.hasClass('youtube') then (($element.height() + $element.width()) / 2) * 4 else $element.height() * 2
    $element.wrapInner $('<div></div>').addClass('transform')
    $transform = $element.find('.transform')
    $transform.wrap $('<div></div>').addClass('perspective')
    $perspective = $element.find('.perspective')
    $perspective.velocity('stop', true).velocity
      properties:
        perspective: perspective
      options:
        duration: 1
  up: ($element, scale) ->
    $transform  = parallaxModel.getTransform  $element
    $layers     = parallaxModel.getLayers $element
    pointer = getPointer(event)
    progress = parallaxModel.getPercentageAcross($element, pointer, scale)
    rotate = parallaxModel.getRotate($element, progress)
    edgeOffset = 24
    if $element.is 'article'
      # Offsets element toward middle of page if element too close to edge of page
      if ($element.offset().left - $(window).scrollLeft()) < 144
        translateX = edgeOffset
      else if ($(window).width() - (($element.offset().left - $(window).scrollLeft()) + $element.width())) < 24
        translateX = -edgeOffset
      else
        translateX = 0
    
      if ($element.offset().top  - $(window).scrollTop())  < 144
        translateY = edgeOffset
      else if ($(window).height() - (($element.offset().top - $(window).scrollTop()) + $element.height())) < 24
        translateY = -edgeOffset
      else
        translateY = 0
    else
      translateX = 0
      translateY = 0
    $element.add($element.parents('li')).css
      zIndex: 2
    $transform.velocity('stop', true).velocity
      properties:
        scale: scale
        translateX: translateX
        translateY: translateY
      options:
        easing: constants.velocity.easing.smooth
        duration: parallaxModel.duration
  move: ($element, scale) ->
    $transform  = parallaxModel.getTransform  $element
    $layers     = parallaxModel.getLayers $element
    progress    = parallaxModel.getPercentageAcross($element, getPointer(event), scale)
    rotate      = parallaxModel.getRotate($element, progress)
    event.preventDefault() # Prevent triggering of mouse events on touch
    $.Velocity.hook $transform, 'rotateX', "#{rotate.x}deg"
    $.Velocity.hook $transform, 'rotateY', "#{rotate.y}deg"
    $layers.each ->
      depth = parseFloat $(@).data('parallaxdepth')
      offset =
        x: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').x else 0
        y: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').y else 0
      parallax = constants.style.grid.col * depth
      $.Velocity.hook $(@), 'translateX', "#{offset.x + (parallax * (-1 * (progress.x - .5)))}px"
      $.Velocity.hook $(@), 'translateY', "#{offset.y + (parallax * (-1 * (progress.y - .5)))}px"
  down: ($element, scale) ->
    $transform  = parallaxModel.getTransform  $element
    $layers     = parallaxModel.getLayers $element
    progress    = parallaxModel.getPercentageAcross $element, getPointer(event), scale
    rotate      = parallaxModel.getRotate $element, progress
    console.log 'DOWN!'
    $transform.velocity('stop', true).velocity
      properties:
        scale: (1 + scale) / 2
        rotateX: -rotate.x
        rotateY: -rotate.y
      options:
        easing: parallaxModel.easing
        duration: parallaxModel.duration
  end: ($element, scale) ->
    $transform  = parallaxModel.getTransform  $element
    $layers     = parallaxModel.getLayers $element
    $element.data('closingHover', true)
    $transform = $element.find('.transform')
    $element.add($element.parents('li')).css
      zIndex: ''
    $transform.velocity('stop', true).velocity
      properties:
        scale: 1
        rotateX: 0
        rotateY: 0
        translateY: 0
        translateX: 0
      options:
        easing: constants.velocity.easing.smooth
        duration: parallaxModel.duration
        complete: -> $element.data('closingHover', false)              
    $layers.velocity('stop', true).velocity
      properties:
        scale: 1
        rotateX: 0
        rotateY: 0
        translateX: 0
        translateY: 0
      options:
        easing: constants.velocity.easing.smooth
        duration: parallaxModel.duration
        
window.unparallax = ($transform, duration, easing) -> # TODO: Put in parallax hover class
  $transform.velocity('stop', true).velocity
    properties:
      rotateX: 0
      rotateY: 0
      scale: 1
    options:
      duration: duration
      easing:   easing
        
window.parallaxHover = ($elements, duration, scale) ->
  $elements.each ->
    $element = $(@)
    parallaxView.init $element

    $element.on 'touchstart mouseenter', (event) ->
      if parallaxModel.canParallax $element
        parallaxView.up $element, scale
    $element.on 'touchmove mousemove', (event) ->
      if parallaxModel.canParallax $element
        parallaxView.move $element, scale
    $element.on 'touchend mouseleave', ->
      if parallaxModel.canParallax $element
        parallaxView.end $element, scale
#     $element.on 'touchstart mousedown', ->
#       parallaxView.down $element, scale


window.simpleHover = ($elements, duration, scale) ->
  window.styleUtilities.transformOrigin $elements, 'center', 'center'
  $elements.mouseenter ->
    $(@).velocity('stop', true).velocity
      properties:
        scale: scale
      options:
        duration: duration
        easing: constants.velocity.easing.spring
  $elements.mousedown ->
    $(@).velocity('stop', true).velocity
      properties:
        scale: 1
      options:
        duration: duration
        easing: constants.velocity.easing.smooth
  $elements.mouseup ->
    $(@).velocity('stop', true).velocity
      properties:
        scale: 1
      options:
        duration: duration
        easing: constants.velocity.easing.spring
  $elements.mouseleave ->
    $(@).velocity('stop', true).velocity
      properties:
        scale: 1
      options:
        duration: duration
        easing: constants.velocity.easing.spring
