window.popController =
  init: ($elements, duration, scale) ->
    $elements.each ->
      $element = $(@)
      popView.init $element
      
      # Raises element and pivots
      $element.on 'touchstart mouseenter mousedown', (event) ->
        if popModel.canPop $element
          # Pivot towards pointer if mouse, away from pointer if mousedown or touchstart
          state = 'up' # if event.type is 'mouseenter' then 'up' else 'down'
          $element.data 'popState', state
          popView.start $element, scale
      # Rotates element and translates parallax layers
      $element.on 'touchmove mousemove', (event) ->
        if popModel.canPop $element
          popView.move $element, scale
      # Returns to normal
      $element.on 'touchend mouseleave', ->
        if popModel.canPop $element
          popView.end $element, scale
      # Pop element back up after clicking
      $element.on 'mouseup', ->
        $element.data 'popState', 'up'
        popView.start $element, scale