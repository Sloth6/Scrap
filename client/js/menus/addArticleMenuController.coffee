window.contentControllers ?= {}

contentControllers.newArticle =
  canZoom: true
  init: ($menu) ->
    $input         = $menu.find '.editable'
    $onEditing     = $menu.find('.showOnEditing').hide()
    $onNotEditing  = $menu.find('.showOnNotEditing').show()
    $done          = $menu.find '.done'

    genericText = contentControllers.genericText.init $menu, {
      onChange: (html, text) ->
        if text.length > 0
          $onEditing.show()
          $onNotEditing.hide()
        else
          $onEditing.hide()
          $onNotEditing.show()
    }

    complete = (data) ->
      emitNewArticle data, window.openCollection
      articleController.close $menu

    $done.on 'mouseup', (event) ->
      { text, html } = contentControllers.genericText.getData $menu
      complete html
      event.stopPropagation()

    # Bind paste event.
    $input.bind "paste", () ->
      return unless $input.text() == ''
      # Use .text() to get link without divs around it
      setTimeout (() ->complete $input.text()), 20

    # File uploading.
    $menu.find('input.file-input').click (event) ->
      event.stopPropagation()
      genericText.clear()

    $menu.find('form.upload').fileupload fileuploadOptions()

  open: ($menu) ->
    $input = $menu.find '.editable'
    $input.focus()

  close: ($menu) ->
    contentControllers.genericText.reset $menu
