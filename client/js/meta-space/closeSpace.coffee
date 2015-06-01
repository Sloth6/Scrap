$ ->
  $('.back').click (event) ->
    event.preventDefault()
    $('.metaspace').addClass('closed');
    $('.metaspace').removeClass('open');
    $(".metaspace").css("transform", "translate3d(0px, 0px, 0px)");
    $(".metaspace > section.content").css("transform", "scale3d("+1.0/scaleMultiple+","+ 1.0/scaleMultiple+","+ 1.0+")")
    $(".spacePreview").not($(this)).removeClass("hidden")
    $(".spacePreview").removeClass('open');

    $('ul.menu.settings').removeClass('hidden')
    $('h1.logo').removeClass('hidden')
    $('a.back').addClass('hidden')

    setTimeout (->
      $('.spaceFrame').remove()
    ), 1000 # duration of animation
