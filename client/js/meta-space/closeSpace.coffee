$ ->
  $('.home').click (event) ->
    event.preventDefault()
    $('.home').hide()
    $('.spaceFrame').parent().removeClass("open")
    setTimeout (->
      $('.spaceFrame').remove()
    ), 2000 # duration of animation
