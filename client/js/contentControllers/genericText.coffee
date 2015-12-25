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
    $editable.attr 'contentEditable', 'true'
    $done.removeClass 'invisible'
    $('body').on 'mousedown', stopEditingText

  stopEditingText = () ->
    $card.add($content).removeClass 'editing'
    $editable.attr 'contentEditable', 'false'
    $done.addClass 'invisible'
    $('body').on 'mousedown', stopEditingText
  
  $content.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY
    e.stopPropagation()

  $content.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    startEditingText $(@) unless $(@).hasClass('editing')

  $content.find('a.done').click (event) ->
    stopEditingText $content
    event.preventDefault()

  $editable.
    css('overflow-y':'auto', 'max-height': maxHeight).
    on('blur', () ->
      #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
      $('<div contenteditable="true"></div>').appendTo('body').focus().remove()
    )

  stopPropagation = (event) ->
    return if Math.abs(event.deltaX) > Math.abs(event.deltaY)
    return unless $editable.hasScrollBar()
    if window.isScrolling
      event.preventDefault()
    else
      event.stopPropagation()

  $editable.
    scroll(stopPropagation).
    mousewheel(stopPropagation)
