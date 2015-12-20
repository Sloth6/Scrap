lengthForLong = 500

startEditingText = (elem) ->
  card = elem.find('.card')
  card.add(elem).addClass 'editing'
  elem.find('.editable').attr 'contentEditable', 'true'
  elem.find('.done').removeClass 'invisible'

stopEditingText = (elem) ->
  card = elem.find('.card')
  card.add(elem).removeClass 'editing'
  elem.find('.editable').attr 'contentEditable', 'false'
  elem.find('.done').addClass 'invisible'

textFormat = (elems) ->
  elems.each () ->
    editable = $(@).find('.editable')

    if editable.text().length < lengthForLong and !$(@).hasClass('short')
      $(@).addClass('short').removeClass('long')
      collectionViewController.draw $('.collection.open')
    
    else if editable.text().length > lengthForLong and !$(@).hasClass('long')
      $(@).addClass('long').removeClass('short')
      collectionViewController.draw $('.collection.open')

initText = ($content) ->
  collectionKey  = $content.data 'collectionkey'
  articleId = $content.attr 'id'
  timeout   = null
  emitInterval = 200
  maxHeight = 700

  $content.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  $content.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    startEditingText $(@) unless $(@).hasClass('ediitng')

  $content.find('a.done').click (event) ->
    stopEditingText $content
    event.preventDefault()

  $content.find('.editable').on 'DOMSubtreeModified', () ->
    textFormat $content
    clearTimeout timeout if timeout
    content = @innerHTML
    timeout = setTimeout (() ->
      socket.emit 'updateArticle', { collectionKey, userId, articleId, content }
    ), emitInterval

  stopPropagation = (event) ->
    if window.isScrolling
      event.preventDefault()
    else
      event.stopPropagation()

  $content.find('.editable').
    scroll(stopPropagation).
    mousewheel(stopPropagation).
    css('overflow-y':'auto', 'max-height': maxHeight).
    on('blur', () ->
      #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
      $('<div contenteditable="true"></div>').appendTo('body').focus().remove()
    )
  
  if $content.find('.editable').text().length < lengthForLong
    $content.addClass 'short'
  else
    $content.addClass 'long'
