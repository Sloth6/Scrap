makeModifiable = (elems, socket) ->
  elems.on 'click', () ->
    elem = $(this)
    return if elem.hasClass('editing')
    stopEditing()
    
    id = elem.attr 'id'
    window.maxZ += 1
    z = window.maxZ
    elem.zIndex z
    
  
    socket.emit 'updateElement', { elementId: id, final: false, userId }
    elem.addClass 'editing'

    p = elem.find '.card > p'
    text = p.html().replace /<br>/g, '\n'
    form = $ "<textarea class='modify' name='content'>#{text}</textarea>"
    elem.find('.card').prepend(form)
    p.hide()

    form.focus().autoGrow().on 'keyup', (event) ->
      if not(event.keyCode is 13 and not event.shiftKey)
        content = $('textarea[name=content]').val().slice(0, -1)
        # socket.emit 'updateElement', { elementId: id, content, final: false, userId }
    

stopEditing = () ->
  socket = io.connect()
  elem = $('.editing')
  return unless elem.length
  p = elem.find '.card > p'
  content = $('textarea[name=content]').val()
  form = elem.find 'textarea'

  p.html content.replace /\n/g, '<br>'
  p.show()
  elem.find('.card').prepend(p)
  form.remove()
  elem.removeClass('editing')
  socket.emit 'updateElement', { elementId: elem.attr('id'), content, final: true, userId }

$ ->
  socket = io.connect()
  makeModifiable $('article.text'), socket
  $(window).click (e) -> # If we click off the element while editing.
    stopEditing() if $(event.target).hasClass('container')
      