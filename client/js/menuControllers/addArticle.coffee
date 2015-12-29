'use strict'
defaultText = '<p>Write a note or paste a link</p>'

window.initAddArticle = ($menu) ->
  collectionkey = $menu.data 'collectionkey'
  input         = $menu.find '.editable'

  genericText = initGenericText $menu, {
    clearOnDone: true
    onDone: (text) ->
      emitNewArticle text, collectionkey
  }
  
  $menu.find('input.file-input').click (event) ->
    event.stopPropagation()
    genericText.clear()

  $menu.find('form.upload').fileupload fileuploadOptions(collectionkey)
    
  # Bind paste event.
  input.bind "paste", () ->
    return unless input.text() == ''
    setTimeout (() =>
      # use .text() to get link without divs around it
      emitNewArticle input.text(), collectionkey
      genericText.clear()
    ), 20

  
  # focus: () ->
  #   $menu.addClass 'focus'
  #   $menu.addClass('typing')
  #   $menu.find('.done').show()
  #   $menu.find('.done').removeClass 'invisible'
  #   $menu.find('.upload').hide()
  #   $menu.find('.editable').focus()

  #   return false
    
  # reset: () ->
  #   $menu.find('.editable').html('')
  #   $menu.find('.editable').get(0).blur()
  #   $menu.find('.upload').show()
  #   $menu.find('.done').hide()
  #   $menu.removeClass 'focus'
  #   $menu.removeClass 'slideInFromSide'
  #   $menu.removeClass 'typing'

    
  # $menu.click (event) ->
  #   if $menu.hasClass 'onEdge'
  #     if $menu.hasClass 'slideInFromSide'
  #       focus()
  #     else
  #       $menu.addClass('slideInFromSide')
  #   else
  #     focus()

  # $('body').click (event) ->
  #   event.stopPropagation()
  #   $menu.removeClass('slideInFromSide')
  
  # input.on 'blur', () ->
  #   #  Blur with empty text area
  #   if content() == ''
  #     reset()
  #     $menu.find('.card').removeClass 'editing'
  #     $menu.find('.done').addClass 'invisible'
  #     $menu.find('.upload').show()
  #   else 
  #     $menu.find('.upload').hide()
  

  # Bind submit event
  # $menu.find('a.submit').click (event) ->
  #   emitNewArticle content(), collectionkey
  #   reset()
  #   event.preventDefault()
  #   event.preventDefault()

  # # Bind cancel event
  # $menu.find('a.cancel').click (event) ->
  #   reset()
  #   event.stopPropagation()
  #   event.preventDefault()
    

