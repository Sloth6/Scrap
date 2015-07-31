makeModifiable = (elems) ->
  elems.each () ->
    elem = $(@)
    spaceKey = elem.parent().parent().data 'spacekey'
    elementId = elem.attr 'id'
    form = elem.find('.editable')
    timeout = null

    # form.bind 'input propertychange', () ->
    form.on 'DOMSubtreeModified', () ->
      # console.log @innerHTML
      # if @clientHeight < @scrollHeight
      #   elem.addClass 'long'
      # else
      #   elem.removeClass 'long'

      clearTimeout timeout if timeout
      content = @innerHTML# $(@).html().replace(/<br>/g, '\n')
      # console.log content
      timeout = setTimeout (() ->
        socket.emit 'updateElement', { spaceKey, userId, elementId, content }
      ), 1000

$ ->
  makeModifiable $('.element.text')
