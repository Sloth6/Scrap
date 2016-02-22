window.cursorView =
  start: (label) ->
    console.log 'start'
    $cursor = $('.cursor')
    $cursor.text(label)
#     $cursor.text(label).velocity
#       properties:
#         scale: [1, 0]
#         rotateZ: [0, (Math.random() - .5) * 45]
#       options:
#         duration: 250
#         easing: constants.velocity.easing.smooth
#         begin: -> $cursor.show()
    $cursor.show()
    $('body').mousedown -> $cursor.css '-webkit-text-fill-color', 'black'
    $('body').mouseup   -> $cursor.css '-webkit-text-fill-color', ''
    $('body, article').css
      cursor: 'none'
      
#   switch: (label) ->
#     $cursor = $('.cursor')
#     if label isnt $cursor.text()
#       $cursor.text(label)
    
  end: ->
    console.log 'end'
    $cursor = $('.cursor')
    $cursor.velocity
      properties:
        scale: 0
        rotateZ: [0, (Math.random() - .5) * 45]
      options:
        duration: 250
        easing: constants.velocity.easing.smooth
        complete: -> $cursor.hide()
    $('body').css
      cursor: ''
    
  move: (event) ->
    $cursor = $('.cursor')
    x = event.clientX - $cursor.width()  / 2 # * 1.5
    y = event.clientY - $cursor.height() / 2 # * 2
    $.Velocity.hook $cursor, 'translateX', "#{x}px"
    $.Velocity.hook $cursor, 'translateY', "#{y}px"
    