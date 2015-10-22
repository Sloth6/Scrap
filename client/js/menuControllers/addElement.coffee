defaultText = '<p>Write a note or paste a link</p>'

addElementController =
  #  Open closed menu items
  init: (menu) ->
    
    spacekey = menu.data 'spacekey'
    input    = menu.find '.editable'

    content = () ->
      input.html()
    
    slideInFromSide = () ->
      if menu.hasClass 'peek'
        menu.removeClass 'peek'
        menu.addClass 'slideInFromSide'
        menu.find('.editable').select()
        menu.find('.upload').show()
  
    slideBackToSide = () ->
      if menu.hasClass('slideInFromSide') and !menu.hasClass('focus')
        menu.addClass 'peek'
        menu.removeClass 'slideInFromSide'

    input.on 'focus', () ->
      console.log 'blue', input[0]
      menu.addClass 'focus'
      menu.find('.card').addClass 'editing'
      menu.find('.done').removeClass 'invisible'
      menu.find('.upload').hide()
      return false

    input.on 'blur', () ->
      #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
      $('<div contenteditable="true"></div>').appendTo('body').focus().remove()
    #   # Blur with empty text area
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
      return unless content() == ''
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
    input = menu.find '.editable'
    input.html('')
    menu.removeClass 'focus'
    menu.find('.card').removeClass 'editing'
     
$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)