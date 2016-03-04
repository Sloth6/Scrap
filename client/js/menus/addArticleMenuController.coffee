window.contentControllers ?= {}

contentControllers['newArticle'] =
  canZoom: true
  init: ($menu) ->
    $input = $menu.find '.editable'
    $onEditing  = $menu.find('.showOnEditing').hide()
    $onNotEditing  = $menu.find('.showOnNotEditing').show()

    genericText = contentControllers['genericText'].init $menu, {
      onDone: (text) ->
        emitNewArticle text, window.openCollection
        articleController.close $menu
        # contentControllers.newArticle.close $menu
      onChange: (dom, text) ->
        if text.length > 0
          $onEditing.show()
          $onNotEditing.hide()
        else
          $onEditing.hide()
          $onNotEditing.show()
    }

    contentControllers.genericText.reset $menu

    $menu.find('input.file-input').click (event) ->
      event.stopPropagation()
      genericText.clear()

    $menu.find('form.upload').fileupload fileuploadOptions()

    # Bind paste event.
    $input.bind "paste", () ->
      return unless $input.text() == ''
      setTimeout (() ->
        # Use .text() to get link without divs around it
        emitNewArticle $input.text(), window.openCollection
        articleController.close $menu
      ), 20

  open: ($menu) ->
    $input = $menu.find '.editable'
    $input.focus()

  close: ($menu) ->
    console.log 'closing menu', $menu.length
    containerController.removeArticle $menu
    # $menu.hide()

