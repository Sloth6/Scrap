window.popModel =
  easing: [20, 10] # TODO: Why is constants.velocity.easing.smooth undefined?
  duration: 500
  canPop: ($element) ->
    not ($element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover') or $element.hasClass('ui-draggable-dragging') or !$element.data('popEnabled'))
  getTransform: ($element) ->
    $element.find('.transform')
  getLayers: ($element) ->
    $element.find('.popLayer')
  getPercentageAcross: ($element, pointer, scale) ->
    # If article, compensate for global scale
    offsetGlobalScale = if $element.is('article') then 1 / (constants.style.globalScale) else 1
    offsetX = $element.offset().left - $(window).scrollLeft()
    offsetY = $element.offset().top  - $(window).scrollTop()
    progressY = offsetGlobalScale * Math.max(0, Math.min(1, (pointer.y - offsetY) / ($element.height() * scale)))
    progressX = offsetGlobalScale * Math.max(0, Math.min(1, (pointer.x - offsetX) / ($element.width()  * scale)))
    { x: progressX, y: progressY }
  getRotate: ($element, progress) ->
    maxRotateY = 22
    maxRotateX = 22
    rotateX = maxRotateY * (progress.y - .5)
    rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
    # If being raised or depressed towards pointer
    if $element.data('popState') is 'up'
      { x: rotateX, y: rotateY}
    else # if $element.data('popState') is 'down'
      { x: -rotateX, y: -rotateY}
