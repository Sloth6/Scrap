window.cursorView =
  start: (label) ->
    console.log 'start'
    $cursor = $('.cursor')
    if (label isnt $cursor.text()) and $cursor.text().length
#       $cursor.text(label)
      $cursor.find('.first').velocity
        properties:
          opacity: [0, 1]
        options:
          duration: 125
          easing: 'linear'
      $cursor.find('.second').text(label).velocity
        properties:
          opacity: [1, 0]
        options:
          duration: 125
          easing: 'linear'
          complete: ->
            $cursor.find('.first').text('')
            $cursor.find('.second').text(label).css('opacity', 1)
#           complete: ->
#             $cursor.text(label)
#             $cursor.velocity
#               properties:
#                 scale: 1
# #                 rotateZ: '+=360'
# #                 opacity: 1
#               options:
#                 duration: 250
#                 easing: constants.velocity.easing.spring
    else if $cursor.text().length < 1
      $cursor.velocity
        properties:
          scale: [1, 0]
#           rotateZ: [0, -180]
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          begin: ->
            $cursor.show()
            $cursor.find('.first').text(label)
    else
      return
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
        rotateZ: [0, -180]
      options:
        duration: 250
        easing: constants.velocity.easing.smooth
        complete: ->
          $cursor.hide()
          $('body').css
            cursor: ''
    
  move: (event) ->
    $cursor = $('.cursor')
    x = event.clientX - $cursor.width()  / 2 # * 1.5
    y = event.clientY - $cursor.height() / 2 # * 2
    $.Velocity.hook $cursor, 'translateX', "#{x}px"
    $.Velocity.hook $cursor, 'translateY', "#{y}px"
    