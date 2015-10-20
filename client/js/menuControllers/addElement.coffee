defaultText = '<p>Write a note or paste a link</p>'

addElementController =
  #  Open closed menu items
  init: (menu) ->
    
    spacekey = menu.data 'spacekey'
    input    = menu.find '.textInput'

    content = () ->
      input.html()
    
    slideInFromSide = () ->
      if menu.hasClass 'peek'
        menu.removeClass 'peek'
        menu.addClass 'slideInFromSide'
        menu.find('textarea').select()
        menu.find('.upload').show()
  
    slideBackToSide = () ->
      if menu.hasClass('slideInFromSide') and !menu.hasClass('focus')
        menu.addClass 'peek'
        menu.removeClass 'slideInFromSide'

    input.on 'focus', () ->
      if content() is defaultText
        input.html('')
      menu.addClass 'focus'
      menu.find('.card').addClass 'editing'
      menu.find('.done').removeClass 'invisible'
      menu.find('.upload').hide()

    input.on 'blur', () ->
      # Blur with empty text area
      if content() == ''
        menu.removeClass 'focus'
        slideBackToSide()
        addElementController.reset menu
        menu.find('.card').removeClass 'editing'
        menu.find('.done').addClass 'invisible'
        menu.find('.upload').show()
      else 
        menu.find('.upload').hide()
    
    input.bind "paste", () ->
      setTimeout (() =>
        emitNewElement content(), spacekey
        addElementController.reset menu
      ), 20

    menu.find('a.submit').click (event) ->
      menu.removeClass 'focus'
      slideBackToSide()
      emitNewElement content(), spacekey
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
    input = menu.find '.textInput'
    # menu.find('.text input,textarea').val('')
    input.html(defaultText)
    menu.removeClass 'focus'
    menu.find('.card').removeClass 'editing'
     
$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)