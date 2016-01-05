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
  
  $menu.click (event) ->
    if $menu.hasClass('onEdge') and !$menu.hasClass('slideInFromSide') 
      $menu.addClass('slideInFromSide')

  # Bind paste event.
  input.bind "paste", () ->
    return unless input.text() == ''
    setTimeout (() =>
      # use .text() to get link without divs around it
      emitNewArticle input.text(), collectionkey
      genericText.clear()
    ), 20
