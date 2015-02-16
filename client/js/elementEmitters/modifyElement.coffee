makeModifiable = (elem) ->
  modify = () ->
    elem = $(this)
    id = elem.attr('id')
    return if elem.hasClass('editing')

    socket.emit 'updateElement', { elementId: id, final: false, userId }
    elem.addClass('editing')

    p = elem.find '.card > p'
    text = p.html().replace /<br>/g, '\n'
    form = $ "<textarea class='modify' name='content'>#{text}</textarea>"

    elem.find('.card').prepend(form)
    p.remove()

    done = () ->
      content = $('textarea[name=content]').val()
      p.html content.replace /\n/g, '<br>'
      elem.find('.card').prepend(p)
      form.remove()
      elem.removeClass('editing')
      socket.emit 'updateElement', { elementId: id, content, final: true, userId }

    form.focus().autoGrow()
      .on 'keydown', (event) ->
        if event.keyCode is 13 and not event.shiftKey
          done()
      .on 'keyup', (event) ->
        if not(event.keyCode is 13 and not event.shiftKey)
          content = $('textarea[name=content]').val().slice(0, -1)
          socket.emit 'updateElement', { elementId: id, content, final: false, userId }

  elem.on 'dblclick', modify
  elem.mousedown () -> window.dontAddNext = true

$ ->
  socket = io.connect()
  makeModifiable $('.card.comment.text').parent()