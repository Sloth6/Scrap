'use strict'
defaultText = '<p>Write a note or paste a link</p>'

window.addArticleMenuController =
  init: ($form) ->
    $button = $('.addForm .headerButton')
    input = $form.find '.editable'
    $form.hide()

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
    input.bind "paste", () ->
      return unless input.text() == ''
      setTimeout (() ->
        # Use .text() to get link without divs around it
        emitNewArticle input.text(), window.openCollection
        genericText.clear()
      ), 20

    $button.hover(
      (() ->
        $button.velocity
          properties:
            translateY: 24
            translateX: 36
          options:
            duration: 500
            easing: [20, 10]
      ),
      (() ->
        $button.velocity
          properties:
            translateY: 0
            translateX: 0
          options:
            duration: 500
            easing: [20, 10]
      )
    )

    showForm = (event) ->
      event.stopPropagation()
      $button.velocity
        properties:
          translateY: [-$button.height() * 2, 0]
          translateX: [-$button.width() * 2, 0]
          rotateZ: [180 * (Math.random() - .5), 0]
        options:
          duration: 500
          easing: [20, 10]
          complete: -> $(@).hide()
      $form.velocity
        properties:
          translateY: [72, -$form.height() * 2]
          translateX: [72, -$form.width() * 2]
          rotateZ: [-11 * Math.random(), 180 * (Math.random() - .5)]
        options:
          duration: 500
          easing: [20, 10]
          begin: -> $form.show()

    hideForm = ->
      $button.velocity
        properties:
          translateY: 0
          translateX: 0
          rotateZ: 0
        options:
          duration: 500
          easing: [20, 10]
          begin: -> $(@).show()
      $form.velocity 'reverse', {
        complete: -> $form.hide()
      }

    $('.addForm').click (event) -> showForm(event)
    $('body').click -> hideForm()
