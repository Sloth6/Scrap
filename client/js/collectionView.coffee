stopProp = (e) -> e.stopPropagation()

window.collectionView =
	shrinkOnDragOffMenu: ($collection) ->
    $collection.find('a').trigger('mouseleave').velocity
      properties:
        scale: .5
        rotateX: 0
        rotateY: 0
        translateX: 0
        translateY: 0
      options:
        queue: false
        easing: constants.velocity.easing.spring
        duration: 250
    $($collection).hover stopProp, stopProp
    
  mouseenter: ($collection) ->
    cursorView.end()
    
  mouseleave: ($collection) ->
    cursorView.start '✕'
    
  showSettings: ($collection) ->
    $settings = $collection.find '.collectionSettings'
    $collection.velocity('stop', true).velocity
      properties:
        height: "+=#{$settings.height() * 1.5}"
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
    $settings.velocity('stop', true).velocity
      properties:
        scale: [1, 0]
        opacity: [1, 0]
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        begin: -> $settings.show()
  
  hideSettings: ($collection) ->
    $settings = $collection.find '.collectionSettings'
    $settings.velocity('stop', true).velocity
      properties:
        scale: 0
        opacity: 0
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        complete: -> $settings.hide()
    $collection.velocity('stop', true).velocity
      properties:
        height: $collection.find('a, input').height()
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        
  hide: ($collections) ->
    $collections.each ->
      $(@).velocity('stop', true).velocity
        properties:
          scale: 0
          opacity: 0
          height: 0
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          complete: => $(@).hide()

  show: ($collections) ->
    $collections.each ->
      $(@).velocity('stop', true).velocity
        properties:
          scale: 1
          opacity: 1
          height: $(@).data 'nativeHeight'
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          begin: => $(@).show()

window.rotateColor = ($elements, hue)->
  $elements.css
    '-webkit-text-fill-color': "hsl(#{hue},100%,75%)"

