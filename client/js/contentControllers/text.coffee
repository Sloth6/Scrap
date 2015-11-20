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
      collectionViewController.draw $('.collection.open')
    
    else if editable.text().length > lengthForLong and !$(@).hasClass('long')
      $(@).addClass('long').removeClass('short')
      collectionViewController.draw $('.collection.open')

# Bind events on article.text articles.
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
    collectionKey  = elem.data 'collectionkey'
    articleId = elem.attr 'id'
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
        socket.emit 'updateArticle', { collectionKey, userId, articleId, content }
      ), 200

initText = (elems) ->
  elems.each () ->
    editable = $(@).find '.editable'
    if editable.text().length < lengthForLong
      $(@).addClass 'short'
    else
      $(@).addClass 'long'

  bindTextEvents elems
