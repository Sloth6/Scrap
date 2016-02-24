window.cursorController =
  init: ($cursor) ->
    $cursor.hide()
    $('body').mousemove (event) -> cursorView.move event
  