$ ->
  
  socket = io.connect()  
  $('.card.comment.text').mousedown () ->
    window.dontAddNext = true

  # completeCurrent = null
  # $(window).mousedown () -> 
  #   completeCurrent() if completeCurrent)
  #   done()

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

    done = () ->
      content = $('textarea[name=content]').val().slice(0, -1)
      p.html content.replace /\n/g, '<br>'
      elem.prepend(p)
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