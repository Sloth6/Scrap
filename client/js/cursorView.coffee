window.cursorView =
  start: (label, event) ->
    return if pointerType(event) is 'touch'
    $cursor = $('.cursor')
    if (label isnt $cursor.text()) and $cursor.text().length # Switch symbol
      $cursor.text(label)
    else if $cursor.text().length < 1 # Cursor is empty, i.e. first start() call
      $cursor.velocity('stop', true).velocity
        properties:
          scale: [1, 0]
          opacity: [1, 0]
        options:
          duration: 500
          queue: false
          easing: constants.velocity.easing.smooth
          begin: ->
            $cursor.show()
            $cursor.text(label)
    else # Changing to self
      return
    # Make sure cursor is right side up
    $.Velocity.hook $cursor, 'rotateZ', '0deg'
    $('body').mousedown -> $cursor.css '-webkit-text-fill-color', 'black'
    $('body').mouseup   -> $cursor.css '-webkit-text-fill-color', ''
    $('body, article, a, input').css
      cursor: 'none'

  end: ->
    $cursor = $('.cursor')
    $('body, article, a, input').css
      cursor: ''
    $cursor.velocity('stop', true).velocity
      properties:
        scale: 0
        rotateZ: [0, -180]
      options:
        duration: 250
        easing: constants.velocity.easing.smooth
        complete: ->
          $cursor.hide()
          $cursor.text('')
          
  move: (event) ->
    return if pointerType(event) is 'touch'
    $cursor = $('.cursor')
    x = event.clientX - $cursor.width()  / 2 # * 1.5
    y = event.clientY - $cursor.height() / 2 # * 2
    $.Velocity.hook $cursor, 'translateX', "#{x}px"
    $.Velocity.hook $cursor, 'translateY', "#{y}px"

