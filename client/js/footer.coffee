window.footerController =
  init: ($footer) ->
    $actions = $footer.find('ul.actions li.action')
    
    console.log $footer, $actions, 'hi'
    foo = 'wowo'
    
    $footer.velocity
      properties:
        translateY: $footer.height()
      options:
        duration: 1
        
    $actions.each () ->
      $action = $(@)
      $action.velocity
        properties:
          translateY: $footer.height()
          scale: 0
        options:
          duration: 1
      $action.mouseenter () ->
        $action.addClass 'active'
        footerController.in $('.dragging'), $action.data 'action'
      $action.mouseleave () ->
        $action.removeClass 'active'
        footerController.out $('.dragging'), $action.data 'action'
      $action.mouseup () ->
        footerController.drop $('.dragging'), $action.data 'action'
        
  show: ($content) ->
    $footer = $('footer.main')
    $actions = $footer.find('ul.actions li.action')
    isDownloadable = $content.hasClass 'text'
    if isDownloadable
      $footer.find('li.download').show()
    else
      $footer.find('li.download').hide()
    $actions.each () ->
      $(@).velocity
        properties:
          translateZ: 0
          translateY: 0
          scale: 1
        options:
          duration: defaultDuration * 2
          easing: defaultCurve
          delay: $(@).index() * 125
    $footer.velocity
      properties:
        translateY: 0
      options:
        duration: defaultDuration
        easing: defaultCurve
        
  hide: () ->
    $footer = $('footer.main')
    $actions = $footer.find('ul.actions li.action')
    $actions.each () ->
      $(@).velocity
        properties:
          translateZ: 0
          translateY: $footer.height()
          scale: 0
        options:
          delay: $(@).index() * 125
    $footer.velocity
      translateY: $footer.height()
      
  in: ($content, action) ->
    $content.velocity
      properties:
        scale: 1/2
      options:
        duration: defaultDuration
        easing: bouncyCurve
      
  out: ($content, action) ->
    unless $content.data 'deleting'
      $content.velocity
        properties:
          scale: 1
        options:
          duration: defaultDuration
          easing: bouncyCurve
      
  drop: ($content, action) ->
    $content.data 'deleting', true
    $content.addClass 'deleting'
    switch action
      when 'delete'
        console.log '🚫!', $content
        onDelete $content
      when 'download'
        console.log '⬇️!'
    