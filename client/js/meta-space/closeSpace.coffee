$ ->
  $('.home').click (event) ->
    event.preventDefault()
    $(".draggable").not($(this)).removeClass("hidden")
    $('.home').hide()
    $('.spaceFrame').parent().removeClass("open")
    setTimeout (->
      $('.spaceFrame').remove()
    ), 2000 # duration of animation
