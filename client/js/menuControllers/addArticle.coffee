defaultText = '<p>Write a note or paste a link</p>'

addArticleController =
  #  Open closed menu items
  init: (menu) ->
    
    collectionkey = menu.data 'collectionkey'
    input    = menu.find '.editable'

    content = () ->
      input.html()
    
    input.on 'focus', () ->
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
        # slideBackToSide()
        addArticleController.reset menu
        menu.find('.card').removeClass 'editing'
        menu.find('.done').addClass 'invisible'
        menu.find('.upload').show()
      else 
        menu.find('.upload').hide()
    
    input.bind "paste", () ->
      return unless content() == ''
      setTimeout (() =>
        emitNewArticle content(), collectionkey
        addArticleController.reset menu
      ), 20

    menu.find('a.submit').click (event) ->
      menu.removeClass 'focus'
      # slideBackToSide()
      emitNewArticle content(), collectionkey
      addArticleController.reset menu
      event.preventDefault()

    menu.find('a.cancel').click (event) ->
      menu.removeClass 'focus'
      # slideBackToSide()
      addArticleController.reset menu
      event.preventDefault()

    # menu.click(() ->
    #   slideInFromSide()
    # )
    
  reset: (menu) ->
    input = menu.find '.editable'
    input.html('')
    menu.removeClass 'focus'
    menu.find('.card').removeClass 'editing'
     
$ ->
  $('.addArticleForm').each () ->
    addArticleController.init $(@)