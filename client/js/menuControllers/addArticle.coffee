'use strict'
defaultText = '<p>Write a note or paste a link</p>'

window.initAddArticleForm = () ->
  $form = $('.addArticleForm')
  input = $form.find '.editable'

  genericText = initGenericText $form, {
    clearOnDone: true
    onDone: (text) ->
      emitNewArticle text, window.openCollection
  }
  
  $form.find('input.file-input').click (event) ->
    event.stopPropagation()
    genericText.clear()

  # $form.find('form.upload').fileupload fileuploadOptions(collectionkey)
  
  # Bind paste event.
  input.bind "paste", () ->
    return unless input.text() == ''
    setTimeout (() ->
      # Use .text() to get link without divs around it
      emitNewArticle input.text(), window.openCollection
      genericText.clear()
    ), 20
