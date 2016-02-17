# TODO: re-refactor and imprive

window.parallaxHover = ($elements) ->
  getProgressValues = ($element, scale) ->
    # if article, compensate for global scale
    offsetGlobalScale = if $element.is('article') then 1 / (constants.style.globalScale) else 1
    offsetX = $element.offset().left - $(window).scrollLeft()
    offsetY = $element.offset().top  - $(window).scrollTop()
    progressY = offsetGlobalScale * Math.max(0, Math.min(1, (event.clientY - offsetY) / ($element.height() * scale)))
    progressX = offsetGlobalScale * Math.max(0, Math.min(1, (event.clientX - offsetX) / ($element.width()  * scale)))
    { x: progressX, y: progressY }
  getRotateValues = ($element, progress) ->
    # TODO: extra fix below
    maxRotateY = if $element.is('a') then 22 else 22
    maxRotateX = if $element.is('a') then 22 else 22
    rotateX = maxRotateY * (progress.y - .5)
    rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
    { x: rotateX, y: rotateY}
  $elements.each ->
    $element = $(@)
    $layers = $element.find('.parallaxLayer')
    scale = if $element.is('a') then 1.25 else 1.5
    duration = 500
    $element.addClass 'parallaxHover'

    $element.wrapInner '<span></span>' if $element.is('a')
    perspective = if $element.hasClass('image') then $element.height() * 8 else $element.height() * 2
    $element.wrapInner $('<div></div>').addClass('transform')
    $transform = $element.find('.transform')
    $transform.wrap $('<div></div>').addClass('perspective')
    $perspective = $element.find('.perspective')
    $perspective.velocity
      properties:
        perspective: perspective
      options:
        duration: 1

    $element.mouseenter (event) ->
        # console.log $element.attr 'class'
        # console.log $element.hasClass('open') or $element.hasClass('obscured') or $element.hasClass('ui-draggable-dragging')
      unless $element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover') or $element.hasClass('ui-draggable-dragging')
        progress = getProgressValues($element, scale)
        rotate = getRotateValues($element, progress)
        # offset if element too close to edge
        if $element.is 'article'
          translateY = if ($element.offset().top  - $(window).scrollTop() ) < 72 then 48 else 0
          translateX = if ($element.offset().left - $(window).scrollLeft()) < 72 then 48 else 0
        else
          translateY = 0
          translateX = 0
        $element.add($element.parents('li')).css
          zIndex: 2
        $transform.velocity
          properties:
            scale: scale
            translateX: translateX
            translateY: translateY
          options:
            easing: constants.velocity.easing.smooth
            duration: duration
        $layers.each ->
          depth = parseFloat $(@).data('parallaxdepth')
          offset =
            x: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').x else 0
            y: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').y else 0
            # $(@).velocity
            #   properties:
            #     translateZ: 500 * depth #(((scale - 1) + depth) / 2) + 1 # average depth with scale of whole $element
            #   options:
            #     easing: constants.velocity.easing.smooth
            #     duration: duration
    $element.mousemove (event) ->
      unless $element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover') or $element.hasClass('ui-draggable-dragging')
        $transform = $element.find('.transform')
        progress = getProgressValues($element, scale)
        rotate = getRotateValues($element, progress)
        $.Velocity.hook $transform, 'rotateX', "#{rotate.x}deg"
        $.Velocity.hook $transform, 'rotateY', "#{rotate.y}deg"
        $layers.each ->
          depth = parseFloat $(@).data('parallaxdepth')
          offset =
            x: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').x else 0
            y: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').y else 0
          parallax = 72 * depth
          $.Velocity.hook $(@), 'translateX', "#{offset.x + (parallax * (-1 * (progress.x - .5)))}px"
          $.Velocity.hook $(@), 'translateY', "#{offset.y + (parallax * (-1 * (progress.y - .5)))}px"
          # console.log progress.y
    $element.mouseleave ->
      unless $element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover') or $element.hasClass('ui-draggable-dragging')
        $element.data('closingHover', true)
        $transform = $element.find('.transform')
        $element.add($element.parents('li')).css
          zIndex: ''
        $transform.velocity
          properties:
            scale: 1
            rotateX: 0
            rotateY: 0
            translateY: 0
            translateX: 0
          options:
            queue: false
            easing: constants.velocity.easing.smooth
            duration: duration
            complete: ->
                # $transform.children().appendTo $element
                # $transform.unwrap $element.find('.perspective')
                # $transform.remove()
                # $element.find('.perspective').remove()
              $element.data('closingHover', false)

        $layers.velocity
          properties:
            scale: 1
            rotateX: 0
            rotateY: 0
            translateX: 0
            translateY: 0
          options:
            easing: constants.velocity.easing.smooth
            duration: duration
            queue: false
