$ ->
  $('.back').click (event) ->
    event.preventDefault()
    $('.metaspace').addClass('closed');
    $('.metaspace').removeClass('open');
    $(".metaspace").css("transform", "scale3d("+1/scaleMultiple+","+1/scaleMultiple+",1) translate3d(0px, 0px, 0px)");
#     $(".draggable").not($(this)).removeClass("hidden")
    setTimeout (->
      $('.spaceFrame').remove()
    ), 2000 # duration of animation
