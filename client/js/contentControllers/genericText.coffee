window.initGenericText = ($content, options) ->
  $done     = $content.find '.done'
  $cancel   = $content.find '.cancel'
  $editable = $content.find '.editable'
  $card     = $content.find '.card'

  maxHeight = $(window).height() - marginTop - 100

  unless $done.length
    throw 'generticText object does not have done'+ $content[0]

  unless $editable.length
    throw 'generticText object does not have cancel'+ $content[0]

  if options.onChange?
    $editable.on 'DOMSubtreeModified', () ->
      options.onChange @innerHTML

  startEditingText = () ->
    $card.add($content).addClass 'editing'
    $done.removeClass 'invisible'
    $('body').on 'mousedown', stopEditingText

  stopEditingText = () ->
    $card.add($content).removeClass 'editing'
    $done.addClass 'invisible'
    $('body').off 'mousedown', stopEditingText
  
  stopPropagation = (event) ->
    return if Math.abs(event.deltaX) > Math.abs(event.deltaY)
    return unless $editable.hasScrollBar()
    if window.isScrolling
      event.preventDefault()
    else
      event.stopPropagation()

  #cancel is optional
  # if $cancel.length
  #   $cancel.click () ->
  #     stopEditingText()

  new Pen
    editor: $editable[0]
    stay: false
    list: [
      'blockquote', 'h1', 'h2', 'h3', 'p', 'insertorderedlist', 'insertunorderedlist',
      'indent', 'outdent', 'bold', 'underline' #'italic',
    ]
  
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
