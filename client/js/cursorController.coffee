window.cursorController =
  init: ($cursor) ->
    $cursor.hide()
    $('body').mousemove (event) ->
      cursorView.move event
    # End cursor if mouse leaves window
    $('body').mouseleave (event) ->
      $('body, article, a, input').css
        cursor: ''      
      cursorView.end()
    # Change color on click
#     $('body').mousedown ->
#       $cursor.css '-webkit-text-fill-color', 'black'
#     $('body').mouseup ->
#       $cursor.css '-webkit-text-fill-color', ''
    
  