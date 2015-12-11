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
          scale: .5
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
    isDownloadable = $content.hasClass 'file'
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
          easing: bouncyCurve
          delay: $(@).index() * (defaultDuration / 4)
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
          scale: .5
        options:
          delay: $(@).index() * (defaultDuration / 4)
          duration: defaultDuration * 2
          easing: bouncyCurve
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
    switch action
      when 'delete'
        $content.data 'deleting', true
        $content.addClass 'deleting'
        console.log '🚫!', $content
        onDelete $content
      when 'download'
        url = $content.data 'content'
        $collection = contentModel.getCollection $content
        window.open(url, '_blank')
        collectionViewController.draw $collection, { animate: true }
        console.log '⬇️!'
    