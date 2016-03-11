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
