window.cursorView =
  start: (label, $parent, scale) ->
#     $('.cursor').remove() # Remove old un-removed cursors
    $cursor = $("<div>#{label}</div>").addClass('cursor')
    $cursor.velocity
      properties:
        scale: [scale, 0]
        rotateZ: [0, (Math.random() - .5) * 180]
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        begin: -> $cursor.appendTo($parent)
    $('body').mousedown -> $cursor.css '-webkit-text-fill-color', 'black'
    $('body').mouseup   -> $cursor.css '-webkit-text-fill-color', ''
    $parent.css
      cursor: 'none'
    
  end: ($parent, $cursor) ->
    $cursor.velocity
      properties:
        scale: 0
        rotateZ: [0, (Math.random() - .5) * 180]
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        complete: -> $cursor.remove()
    $parent.css
      cursor: ''
    
  move: (event, scale) ->
    $cursor = $('.cursor')
    x = (event.clientX * scale) - $cursor.width()  / 2 # * 1.5
    y = (event.clientY * scale) - $cursor.height() / 2 # * 2
    $.Velocity.hook $cursor, 'translateX', "#{x}px"
    $.Velocity.hook $cursor, 'translateY', "#{y}px"
    