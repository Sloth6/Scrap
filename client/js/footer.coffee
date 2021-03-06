dragIn = ($content, action) ->
  $content.velocity
    properties:
      opacity: .25
    
dragOut = ($content, action) ->
  unless $content.data 'deleting'
    $content.velocity
      properties:
        opacity: 1
  
drop = ($content, action) ->
  $content.velocity
    properties:
      opacity: 1
  switch action
    when 'delete'
      $content.data 'deleting', true
      $content.addClass 'deleting'
      onDelete $content
    when 'download'
      url = if $content.hasClass 'image' then $content.data('content').original_url else $content.data 'content'
      $collection = contentModel.getCollection $content
      window.open(url, '_blank')
      collectionViewController.draw $collection, { animate: true }
  
window.footerController =
  init: ($footer) ->
    $actions = $footer.find('ul.actions li.action')
    
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
        dragIn $('.dragging'), $action.data 'action'
      $action.mouseleave () ->
        $action.removeClass 'active'
        dragOut $('.dragging'), $action.data 'action'
      $action.mouseup () ->
        drop $('.dragging'), $action.data 'action'
        
  show: ($content) ->
    $footer = $('footer.main')
    $actions = $footer.find('ul.actions li.action')
    isDownloadable = $content.hasClass('file') or $content.hasClass('image') or $content.hasClass('video')
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
