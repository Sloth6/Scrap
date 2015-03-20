$ ->
  $('.home').click (event) ->
    event.preventDefault()
    $('.home').hide()
    $('.spaceFrame').parent().removeClass("open")
    setTimeout (->
      $('.spaceFrame').remove()
    ), 500
