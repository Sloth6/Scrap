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
      $action.mouseenter () ->
        $action.addClass 'active'
      $action.mouseleave () ->
        $action.removeClass 'active'
      $action.mouseup () ->
        footerController.drop $('.dragging'), $action.data 'action'
        
  show: ($footer) ->
    $footer.velocity
      properties:
        translateY: 0
      options:
        duration: defaultDuration
        easing: defaultCurve
        
  hide: ($footer) ->
    $footer.velocity
      translateY: $footer.height()
      
  drop: ($content, action) ->
    $content.addClass 'deleting'
    $content.data 'deleting', true
    switch action
      when 'delete'
        console.log '🚫!', $content
        onDelete $content
      when 'download'
        console.log '⬇️!'
    