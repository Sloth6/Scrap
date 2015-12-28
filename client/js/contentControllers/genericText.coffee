'use strict'
window.initGenericText = ($content, options = {}) ->
  $editable = $content.find '.editable'
  $card     = $content.find '.card'
  $actions  = $content.find '.cardActions'
  $done     = $actions.find '.done'
  $cancel   = $actions.find '.cancel'
  
  $actions.find('.showOnEditing').hide()

  maxHeight = $(window).height() - marginTop - 100

  unless $done.length
    throw 'generticText object does not have done'+ $content[0]

  unless $editable.length
    throw 'generticText object does not have editable'+ $content[0]

  hasCancel   = $cancel.length isnt 0 # Cancel button is optional.
  clearOnDone = options.clearOnDone or false
  pen = new Pen {
    editor: $editable[0]
    stay: false # dont block user from reloading page
    list: [
      'blockquote', 'h1', 'h2', 'h3', 'p', 'insertorderedlist',
      'insertunorderedlist', 'indent', 'outdent', 'bold', 'underline' #'italic',
    ]
  }
  startEditingText = () ->
    $card.add($content).addClass 'editing'
    $card.addClass 'typing'
    $actions.find('.showOnEditing').show()
    $actions.find('.showOnNotEditing').hide()
    $('body').on 'mousedown', stopEditingText

  stopEditingText = () ->
    $actions.find('.showOnNotEditing').show()
    $actions.find('.showOnEditing').hide()
    $editable.blur()
    $card.add($content).removeClass 'editing'
    $card.removeClass 'typing'
    # pen.destroy()
    $('body').off 'mousedown', stopEditingText
  
  stopPropagation = (event) ->
    return if Math.abs(event.deltaX) > Math.abs(event.deltaY)
    return unless $editable.hasScrollBar()
    if window.isScrolling
      event.preventDefault()
    else
      event.stopPropagation()

  clear = () ->
    $editable.html('')
    stopEditingText()

  if options.onChange?
    $editable.on 'DOMSubtreeModified', () ->
      options.onChange @innerHTML

  $('.pen-menu').mousedown (event) ->
    event.stopPropagation()
    event.preventDefault()
  
  $content.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY
    e.stopPropagation()
  
  $content.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    startEditingText $(@) unless $(@).hasClass('editing')

  $content.find('a.done').click (event) ->
    stopEditingText()
    event.preventDefault()

  $editable.
    css('overflow-y':'auto', 'max-height': maxHeight).
    scroll(stopPropagation).
    mousewheel(stopPropagation)

  $done.click (event) ->
    event.preventDefault()
    options.onDone($editable[0].innerHTML) if options.onDone?
    clear() if clearOnDone

  #cancel is optional
  if hasCancel
    $cancel.click (event) ->
      event.preventDefault()
      clear()

  return { clear, getContent: pen.getContent }
