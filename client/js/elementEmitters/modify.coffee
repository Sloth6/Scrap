startEditing = (elem) ->
  card = elem.find('.card')
  elem.removeClass 'draggable'
  card.addClass 'editing'
  elem.find('.editable').attr 'contentEditable', 'true'
  elem.find('.done').removeClass 'invisible'

stopEditing = (elem) ->
  card = elem.find('.card')
  elem.addClass 'draggable'
  card.removeClass 'editing'
  elem.find('.editable').attr 'contentEditable', 'false'
  elem.find('.done').addClass 'invisible'


makeModifiable = (elems) ->

  elems.mousedown (e) ->
    $(@).data 'lastX', e.clientX
    $(@).data 'lastY', e.clientY

  elems.mouseup (e) ->
    return if $(@).data('lastX') != e.clientX
    return if $(@).data('lastY') != e.clientY
    startEditing $(@) unless $(@).hasClass('ediitng')


  elems.each () ->
    elem = $(@)
    
    # formatText elem
    spaceKey = elem.parent().parent().data 'spacekey'
    elementId = elem.attr 'id'
    form = elem.find('.editable')
    timeout = null

    elem.find('a.done').click () ->
      stopEditing elem
    # elem.click () ->
    #   card = $(@).find('.card')
    #   startEditing(elem) if !card.hasClass('editing')
        

    form.on 'DOMSubtreeModified', () ->
      formatText elem
      clearTimeout timeout if timeout
      content = @innerHTML# $(@).html().replace(/<br>/g, '\n')
      timeout = setTimeout (() ->
        socket.emit 'updateElement', { spaceKey, userId, elementId, content }
      ), 200

$ ->
  makeModifiable $('.element.text')
