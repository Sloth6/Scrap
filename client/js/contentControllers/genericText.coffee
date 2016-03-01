window.contentControllers ?= {}
contentControllers['genericText'] =

  startEditing: ($article) ->
    $editable = $article.find '.editable'
    $card     = $article.find '.card'
    $actions  = $article.find '.cardActions'
    $done     = $actions.find '.done'
    $cancel   = $actions.find '.cancel'

    $card.add($article).addClass 'editing'
    $card.addClass 'typing'
    pen = new Pen {
      editor: $editable[0]
      stay: false # dont block user from reloading page
      list: [
        'blockquote', 'h1', 'h2', 'h3', 'p', 'insertorderedlist',
        'insertunorderedlist', 'indent', 'outdent', 'bold', 'underline' #'italic',
      ]
    }
    pen.focus()
    # $('body').on 'mousedown', defocus

  stopEditing: ($article) ->
    $editable = $article.find '.editable'
    $card     = $article.find '.card'
    $card.add($article).removeClass 'editing'
    $card.removeClass 'typing'
    $editable.blur()
    window.getSelection().removeAllRanges()
    # defocus()
    # $('body').off 'mousedown', defocus

  reset: ($article) ->
    $editable = $article.find '.editable'
    $editable.html('')
    contentControllers['genericText'].stopEditing $article

  init: ($article, options = {}) ->
    $editable = $article.find '.editable'
    $card     = $article.find '.card'
    $actions  = $article.find '.cardActions'
    $done     = $actions.find '.done'

    maxHeight = $(window).height()

    unless $done.length
      throw 'generticText object does not have done'+ $article[0]

    unless $editable.length
      throw 'generticText object does not have editable'+ $article[0]



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

    $done.click (event) ->
      contentControllers.genericText.stopEditing $article
      options.onDone($editable[0].innerHTML) if options.onDone?
      event.preventDefault()
      event.stopPropagation()


    return { content: () -> $editable[0].innerHTML }
