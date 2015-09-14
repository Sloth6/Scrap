addElementController =
  #  Open closed menu items
  init: (menu) ->
    
    spacekey = menu.data 'spacekey'
    input    = menu.find '.textInput'
    
    slideInFromSide = () ->
      if menu.hasClass 'peek'
        console.log 'hey'
        menu.removeClass 'peek'
        menu.addClass 'slideInFromSide'
        menu.find('textarea').select()
        menu.find('.upload').show()
  
    slideBackToSide = () ->
      if menu.hasClass('slideInFromSide') and !menu.hasClass('focus')
        menu.addClass 'peek'
        menu.removeClass 'slideInFromSide'

    menu.find('textarea').on('focus', () ->
      menu.addClass 'focus'
      menu.find('.card').addClass 'editing'
      menu.find('.done').removeClass 'invisible'
      menu.find('.upload').hide()
    )

    menu.find('textarea').on('blur', () ->
    # Blur with empty text area
      if $(@).val() == ''
        menu.removeClass 'focus'
        slideBackToSide()
        addElementController.reset menu
        menu.find('.card').removeClass 'editing'
        menu.find('.done').addClass 'invisible'
        menu.find('.upload').show()
      else 
        menu.find('.upload').hide()
    )
    
    menu.find('textarea').bind "paste", () ->
      setTimeout (() =>
        emitNewElement $(@).val(), spacekey
        addElementController.reset menu
      ), 20

    menu.find('a.submit').click (event) ->
      menu.removeClass 'focus'
      slideBackToSide()
      emitNewElement input.val(), spacekey
      addElementController.reset menu
      event.preventDefault()

    menu.find('a.cancel').click (event) ->
      menu.removeClass 'focus'
      slideBackToSide()
      addElementController.reset menu
      event.preventDefault()

    menu.click(() ->
      slideInFromSide()
    )
    
  reset: (menu) ->
    menu.find('.text input,textarea').val('')
    menu.removeClass 'focus'
    menu.find('.card').removeClass 'editing'
     
$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)