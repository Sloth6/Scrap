makeModifiable = (elems) ->
  elems.each () ->
    elem = $(@)
    spaceKey = elem.parent().parent().data 'spacekey'
    elementId = elem.attr 'id'
    form = elem.find('textarea')
    timeout = null

    form.bind 'input propertychange', () ->
      clearTimeout timeout if timeout
      content = @value.replace(/<br>/g, '\n')
      console.log content
      timeout = setTimeout (() ->
        socket.emit 'updateElement', { spaceKey, userId, elementId, content }
      ), 1000

$ ->
  makeModifiable $('.element.text')
