$ ->
  $('#home').click (event) ->
    event.preventDefault()
    $('#spaceFrame').animate {
      scale: Math.min(300 / $(window).width(), 200 / $(window).height())
    }, 500
    $('#home').hide()
    $('#spaceFrame').parent().animate({
      top: 25
      left: 25
      width: 300
      'border-width': 2
      height: 200
    }, 500, () ->
      $('#spaceFrame').remove()

    )
