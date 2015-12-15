defaultText = '<p>Write a note or paste a link</p>'

addArticleController =
  #  Open closed menu items
  init: ($menu) ->
    
    collectionkey = $menu.data 'collectionkey'
    input    = $menu.find '.editable'

    # function to get content of form
    content = () ->
      input.html()
      
    $menu.click () ->
      $menu.addClass('slideInFromSide')
      $menu.addClass('typing')
      addArticleController.focus $menu
      
    $('body').click (event) ->
      event.stopPropagation()
      $menu.removeClass('slideInFromSide')
    
    input.on 'focus', () ->
      addArticleController.focus $menu

    input.on 'blur', () ->
      #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
      $('<div contenteditable="true"></div>').appendTo('body').focus().remove()
      #   # Blur with empty text area
      if content() == ''
        $menu.removeClass 'focus'
        addArticleController.reset $menu
        $menu.find('.card').removeClass 'editing'
        $menu.find('.done').addClass 'invisible'
        $menu.find('.upload').show()
      else 
        $menu.find('.upload').hide()
    
    # Bind paste event.
    input.bind "paste", () ->
      return unless content() == ''
      setTimeout (() =>
        emitNewArticle content(), collectionkey
        addArticleController.reset $menu
      ), 20

    # Bind submit event
    $menu.find('a.submit').click (event) ->
      $menu.removeClass 'focus'
      addArticleController.reset $menu
      # slideBackToSide()
      emitNewArticle content(), collectionkey
      event.preventDefault()

    # Bind cancel event
    $menu.find('a.cancel').click (event) ->
      $menu.removeClass 'focus'
      addArticleController.reset $menu
      event.preventDefault()

    $menu.find('form.upload').fileupload fileuploadOptions(collectionkey)
    
  focus: ($menu) ->
    $menu.addClass 'focus'
    $menu.find('.card').addClass 'editing'
    $menu.find('.done').removeClass 'invisible'
    $menu.find('.upload').hide()
    $menu.find('.editable').get(0).focus()
    return false
    
  reset: ($menu) ->
    input = $menu.find '.editable'
    input.html('')
    $menu.find('.editable').get(0).blur()
    $menu.removeClass 'focus'
    $menu.removeClass 'slideInFromSide'
    $menu.removeClass 'typing'
    $menu.find('.card').removeClass 'editing'
     
$ ->
  $('.addArticleForm').each () ->
    addArticleController.init $(@)