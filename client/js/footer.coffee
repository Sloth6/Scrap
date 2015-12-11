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
        console.log 'hiiii', $('.dragging').data 'originalCollection'
      $action.mouseleave () ->
        console.log 'out ', $('.dragging').attr 'class'
      $action.mouseup () ->
        console.log 'up ', $('.dragging').attr 'class'
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
    switch action
      when 'delete'
        console.log '🚫!', $content
        onDelete $content
      when 'download'
        console.log '⬇️!'
      #         onDelete $content
    