makeModifiable = (elem, socket) ->
  

  modify = () ->
    elem = $(this)
    id = elem.attr 'id'
    return if elem.hasClass('editing')
  
    socket.emit 'updateElement', { elementId: id, final: false, userId }
    elem.addClass 'editing'

    p = elem.find '.card > p'
    text = p.html().replace /<br>/g, '\n'
    form = $ "<textarea class='modify' name='content'>#{text}</textarea>"

    elem.find('.card').prepend(form)
    p.remove()

    form.focus().autoGrow().on 'keyup', (event) ->
      if not(event.keyCode is 13 and not event.shiftKey)
        content = $('textarea[name=content]').val().slice(0, -1)
        socket.emit 'updateElement', { elementId: id, content, final: false, userId }
      
    clickDone = (e) ->
      # If we click off the element while editing.
      if $(event.target).hasClass('container')
        $(window).off('click', clickDone)
        done()

    done = () ->
      content = $('textarea[name=content]').val()
      p.html content.replace /\n/g, '<br>'
      elem.find('.card').prepend(p)
      form.remove()
      elem.removeClass('editing')
      socket.emit 'updateElement', { elementId: id, content, final: true, userId }

    $(window).click clickDone
      
  elem.on 'click', modify

$ ->
  socket = io.connect()
  makeModifiable $('article.text'), socket