stopProp = (e) -> e.stopPropagation()

window.collectionView =

  init: ($collection) ->
    $settings = $collection.find('.collectionSettings')
    $settings.find('.sharing .add form').hide()

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

  addUser: ($collection) ->
    input         = $collection.find('input[type=email]')
    email         = input.val()
    $li = $('<li>').addClass('user').text email
    $collection.find('ul.users').append $li
    input.val('').blur()

  openAddUserForm: ($collection) ->
    $addSection = $collection.find '.contents .collectionSettings .add'
    $emailInput = $addSection.find 'input[type=email]'
    $button     = $addSection.find 'input.addSomeone[type=button]'
    $form       = $addSection.find 'form'
    $label      = $addSection.find 'label'
    # startingLabel = $label.text()
    # Save label for resetForm later
    # $label.data 'startingLabel', startingLabel
    # $collection.data 'settingsInUse', true
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


window.rotateColor = ($elements, hue)->
  $elements.css
    '-webkit-text-fill-color': "hsl(#{hue},100%,75%)"

