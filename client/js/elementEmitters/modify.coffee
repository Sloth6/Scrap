makeModifiable = (elems) ->
  elems.each () ->
    elem = $(@)
    formatText elem
    spaceKey = elem.parent().parent().data 'spacekey'
    elementId = elem.attr 'id'
    form = elem.find('.editable')
    timeout = null

    form.on 'DOMSubtreeModified', () ->
      formatText elem
      clearTimeout timeout if timeout
      content = @innerHTML# $(@).html().replace(/<br>/g, '\n')
      timeout = setTimeout (() ->
        socket.emit 'updateElement', { spaceKey, userId, elementId, content }
      ), 200

$ ->
  makeModifiable $('.element.text')
