$ ->
  
  socket = io.connect()  
  $('.card.comment.text').mousedown () ->
    window.dontAddNext = true

  # $(window).mousedown () -> done()

  $('.card.comment.text').on 'dblclick', () ->
    elem = $(this)
    id = elem.parent().attr('id')
    return if elem.hasClass('editing')

    socket.emit 'updateElement', { elementId: id, final: false, userId }
    elem.addClass('editing')

    p = elem.children("p")
    text = p.html().replace /<br>/g, '\n'
    form = $ "<textarea class='modify' name='content'>#{text}</textarea>"

    elem.prepend(form)
    p.remove()

    done = (content) ->
      p.html content.replace /\n/g, '<br>'
      elem.prepend(p)
      form.remove()
      elem.removeClass('editing')
      socket.emit 'updateElement', { elementId: id, content, final: true, userId }

    form.focus().autoGrow()
      .on 'keyup', (event) ->
        final = false
        content = $('textarea[name=content]').val().slice(0, -1)
        # console.log content
        # console.log event.keyCode 
        if event.keyCode is 13 and not event.shiftKey
          done content
        else
          socket.emit 'updateElement', { elementId: id, content, final: false, userId }