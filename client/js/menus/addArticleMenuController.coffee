'use strict'

window.addArticleMenuController =
  init: ($form) ->
    $button = $('.addForm .headerButton')
    $input = $form.find '.editable'
    
    $form.hide() # Hide form on load

    genericText = initGenericText $form, {
      clearOnDone: true
      onDone: (text) ->
        emitNewArticle text, window.openCollection
    }

    $form.find('input.file-input').click (event) ->
      event.stopPropagation()
      genericText.clear()

    $form.find('form.upload').fileupload fileuploadOptions()

    # Bind paste event.
    $input.bind "paste", () ->
      return unless $input.text() == ''
      setTimeout (() ->
        # Use .text() to get link without divs around it
        emitNewArticle $input.text(), window.openCollection
        genericText.clear()
      ), 20

  focus: ($form) ->
    $input = $form.find '.editable'
    $input.focus()
    
  hide: ($form) ->
    $form.hide()