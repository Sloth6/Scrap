lengthForLong = 20

startEditingText = (elem) ->
  card = elem.find('.card')
  elem.removeClass 'draggable'
  card.addClass 'editing'
  elem.find('.editable').attr 'contentEditable', 'true'
  elem.find('.done').removeClass 'invisible'

stopEditingText = (elem) ->
  card = elem.find('.card')
  elem.addClass 'draggable'
  card.removeClass 'editing'
  elem.find('.editable').attr 'contentEditable', 'false'
  elem.find('.done').addClass 'invisible'

textFormat = (elems) ->
  elems.each () ->
    editable = $(@).find('.editable')

    if editable.text().length < lengthForLong and !$(@).hasClass('short')
      $(@).addClass('short').removeClass('long')
      collectionRealign()
    
    else if editable.text().length > lengthForLong and !$(@).hasClass('long')
      $(@).addClass('long').removeClass('short')
      collectionRealign()

# Bind events on article.text elements.
bindTextEvents = ($text) ->
  $text.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  $text.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    startEditingText $(@) unless $(@).hasClass('ediitng')

  $text.find('editable').on 'blur', () ->
    #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
    $('<div contenteditable="true"></div>').appendTo('body').focus().remove()

  $text.each () ->
    elem      = $(@)
    spaceKey  = elem.data 'spacekey'
    elementId = elem.attr 'id'
    form      = elem.find('.editable')
    timeout   = null

    elem.find('a.done').click (event) ->
      stopEditingText elem
      event.preventDefault()

    form.on 'DOMSubtreeModified', () ->
      textFormat elem
      clearTimeout timeout if timeout
      content = @innerHTML
      timeout = setTimeout (() ->
        socket.emit 'updateElement', { spaceKey, userId, elementId, content }
      ), 200

textInit = (elems) ->
  elems.each () ->
    editable = $(@).find '.editable'
    if editable.text().length < lengthForLong
      $(@).addClass 'short'
    else
      $(@).addClass 'long'

  bindTextEvents elems
