stopProp = (e) -> e.stopPropagation()

window.collectionView =

  init: ($collection) ->
    $settings = $collection.find('.collectionSettings')
    $settings.find('.sharing .add form').hide()
    # Open add user form on button click
    $settings.find('input.addSomeone').click -> collectionView.addSomeone $collection
    # Make settings hide-able if user blurs email input
    $settings.find('input[type=email]').blur -> 
      $collection.data 'settingsInUse', false
      $('body').mousemove ->
        unless $collection.is('.hover')
          $collection.find('.contents > a').trigger 'mouseleave'
    # Regular cursor on settings
    $settings.mousemove -> cursorView.end()
    $settings.find('.actions input[type=button]').click ->
      $collection.data 'settingsInUse', true
      alert 'Confirmation UI goes here'
      # After completing dialog
      # $collection.data 'settingsInUse', false
    
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
          
  resetForm: ($collection) ->
    $addSection = $collection.find '.contents .collectionSettings .add'
    $emailInput = $addSection.find 'input[type=email]'
    $button     = $addSection.find 'input.addSomeone[type=button]'
    $form       = $addSection.find 'form'
    $label      = $addSection.find 'label'
    # Reset input
    $emailInput.blur().val ''
    # Reset label
    $label.text $label.data('startingLabel')
    $label.addClass 'invisible'
    # Show button
    $button.velocity
      properties:
        scale: 1
        opacity: 1
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
    # Hide form
    $form.velocity
      properties:
        scale: 0
        opacity: 0
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        complete: -> $form.hide()
    $collection.data 'settingsInUse', true
    
  addSomeone: ($collection) ->
    $addSection = $collection.find '.contents .collectionSettings .add'
    $emailInput = $addSection.find 'input[type=email]'
    $button     = $addSection.find 'input.addSomeone[type=button]'
    $form       = $addSection.find 'form'
    $label      = $addSection.find 'label'
    startingLabel = $label.text()
    # Save label for resetForm later
    $label.data 'startingLabel', startingLabel
    $collection.data 'settingsInUse', true
    $button.click ->
      # Show button
      $button.velocity
        properties:
          scale: 0
          opacity: 0
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
      # Hide form
      $form.velocity
        properties:
          scale: [1, 0]
          opacity: [1, 0]
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          begin: -> $form.show()
      # Focus input
      $emailInput.focus()
      # When user types, show label
      $emailInput.on 'input', ->
        $label.removeClass 'invisible'
    # TODO: on submit, do stuff
    # If invalid email
      # $label.text 'Please enter a valid address'
    # Else if successful submit
      # $label.text "#{name@example.com} successfully invited"
      # resetForm $collection
    
      

window.rotateColor = ($elements, hue)->
  $elements.css
    '-webkit-text-fill-color': "hsl(#{hue},100%,75%)"

