addElementController =
  #  Open closed menu items
  init: (menu) ->
    
    spacekey = menu.data 'spacekey'
    input    = menu.find '.textInput'
    
    menu.find('textarea').on('focus', () ->
      menu.find('.done').removeClass 'invisible'
      menu.find('.upload').hide()
    )

    menu.find('textarea').on('blur', () ->
    # Blur with empty text area
      if $(@).val() == ''
        menu.find('.done').addClass 'invisible'
        menu.find('.upload').show()
    )
    
    menu.find('textarea').bind "paste", () ->
      setTimeout (() =>
        emitNewElement $(@).val(), spacekey
        addElementController.reset menu
      ), 20

    menu.find('a.submit').click (event) ->
      emitNewElement input.val(), spacekey
      addElementController.reset menu
      event.preventDefault()

    menu.find('a.cancel').click (event) ->
      addElementController.reset menu
      event.preventDefault()

  reset: (menu) ->
    menu.find('.text input,textarea').val('')
    
showAddElementForm = () ->
  $('.addElementForm.peek').each () ->
    $(@).mouseenter(() ->
      $(@).velocity(
        properties:
          translateX: 800
        options:
          easing: defaultCurve
          duration: 1000
      )
    )

$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)
  showAddElementForm()