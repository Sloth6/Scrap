window.popView =
  init: ($element) ->
    $element.addClass 'pop'
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
  start: ($element, scale) ->
    $transform  = popModel.getTransform  $element
    $layers     = popModel.getLayers $element
    progress    = popModel.getPercentageAcross $element, getPointer(event), scale
    rotate      = popModel.getRotate $element, progress
    $transform.velocity('stop', true).velocity
      properties:
        scale: scale
        rotateX: rotate.x
        rotateY: rotate.y
      options:
        easing: constants.velocity.easing.smooth
        duration: popModel.duration
  move: ($element, scale) ->
    $transform  = popModel.getTransform $element
    $layers     = popModel.getLayers $element
    progress    = popModel.getPercentageAcross($element, getPointer(event), scale)
    rotate      = popModel.getRotate($element, progress)
    # Tilt whole element
    $.Velocity.hook $transform, 'rotateX', "#{rotate.x}deg"
    $.Velocity.hook $transform, 'rotateY', "#{rotate.y}deg"
    # Tilt inner layers
    # console.log $layers
    $layers.each ->
      depth = parseFloat $(@).data('popdepth')
      parallax = constants.style.grid.col * depth
      offset =
        x: if $(@).data('poptranslate') isnt undefined then $(@).data('poptranslate').x else 0
        y: if $(@).data('poptranslate') isnt undefined then $(@).data('poptranslate').y else 0
      translate =
        x: offset.x + (parallax * (-1 * (progress.x - .5)))
        y: offset.y + (parallax * (-1 * (progress.y - .5)))
      # Reverse if element is being depressed
      translate.x *= if $element.data('popState') is 'up' then 1 else -1
      translate.y *= if $element.data('popState') is 'up' then 1 else -1
      $.Velocity.hook $(@), 'translateX', "#{translate.x}px"
      $.Velocity.hook $(@), 'translateY', "#{translate.y}px"
  end: ($element) ->
    $transform  = popModel.getTransform  $element
    $layers     = popModel.getLayers $element
    $element.data('closingHover', true)
    $transform = $element.find('.transform')
    $transform.velocity('stop', true).velocity
      properties:
        scale: 1
        rotateX: 0
        rotateY: 0
        translateY: 0
        translateX: 0
      options:
        easing: constants.velocity.easing.smooth
        duration: popModel.duration
        complete: -> $element.data('closingHover', false)
    $layers.velocity
      properties:
        scale: 1
        rotateX: 0
        rotateY: 0
        translateX: 0
        translateY: 0
      options:
        easing: constants.velocity.easing.smooth
        duration: popModel.duration

# Move on screen if at edge
# edgeOffset = 24
# if $element.is 'article'
#   # Offsets element toward middle of page if element too close to edge of page
#   if ($element.offset().left - $(window).scrollLeft()) < 144
#     translateX = edgeOffset
#   else if ($(window).width() - (($element.offset().left - $(window).scrollLeft()) + $element.width())) < 24
#     translateX = -edgeOffset
#   else
#     translateX = 0
#
#   if ($element.offset().top  - $(window).scrollTop())  < 144
#     translateY = edgeOffset
#   else if ($(window).height() - (($element.offset().top - $(window).scrollTop()) + $element.height())) < 24
#     translateY = -edgeOffset
#   else
#     translateY = 0
# else
#   translateX = 0
#   translateY = 0
