window.contentControllers ?= {}
contentControllers.genericText =
  init: ($article, options = {}) ->
    $editable = $article.find '.editable'
    $card     = $article.find '.card'

    maxHeight = $(window).height()

    unless $editable.length
      throw 'generticText object does not have editable'+ $article[0]

    pen = new Pen {
      editor: $editable[0]
      stay: false # dont block user from reloading page
      list: [
        'blockquote', 'h1', 'h2', 'h3', 'p', 'insertorderedlist',
        'insertunorderedlist', 'indent', 'outdent', 'bold', 'underline' #'italic',
      ]
    }
    # pen.focus()
    $article.data 'pen', pen

    stopPropagation = (event) ->
      return if Math.abs(event.deltaX) > Math.abs(event.deltaY)
      return unless $editable.hasScrollBar()
      if window.isScrolling
        event.preventDefault()
      else
        event.stopPropagation()

    $editable.on 'DOMSubtreeModified', () ->
      if options.onChange?
        options.onChange @innerHTML, $(@).text()

    $('.pen-menu').mousedown (event) ->
      event.stopPropagation()
      event.preventDefault()

    $editable.
      css('overflow-y':'auto', 'max-height': maxHeight).
      scroll(stopPropagation).
      mousewheel(stopPropagation)

    return { content: () -> $editable[0].innerHTML }

  getData: ($article) ->
    $editable = $article.find '.editable'
    return { html:$editable.html(), text:$editable.text() }

  startEditing: ($article) ->
    $editable = $article.find '.editable'
    $card     = $article.find '.card'
    $card.add($article).addClass 'editing'
    $card.addClass 'typing'

    $article.data('pen').focus()

  stopEditing: ($article) ->
    $editable = $article.find '.editable'
    $card     = $article.find '.card'
    $card.add($article).removeClass 'editing'
    $card.removeClass 'typing'
    $editable.blur()
    window.getSelection().removeAllRanges()
    # defocus()

  reset: ($article) ->
    $editable = $article.find '.editable'
    $editable.html('')
    contentControllers.genericText.stopEditing $article
