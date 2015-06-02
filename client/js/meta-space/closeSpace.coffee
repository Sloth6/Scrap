$ ->    
  $('.back').click (event) ->
    event.preventDefault()
    $('.container > header').append(window.userSettings)
#     $('.menu.settings').css('right', '-50vw')
    $('.menu.settings').addClass('hidden')
    
    $('.metaspace').addClass('closed');
    $('.metaspace').removeClass('open');
    $(".metaspace").css("transform", "translate3d(0px, 0px, 0px)");
    $(".metaspace > section.content").css("transform", "scale3d("+1.0/scaleMultiple+","+ 1.0/scaleMultiple+","+ 1.0+")")
    $(".spacePreview").not($(this)).removeClass("hidden")
    $(".spacePreview").removeClass('open');


    setTimeout (->
      $('h1.logo').removeClass('hidden')
      $('a.back').addClass('hidden')
      $('.menu.users').addClass('hidden')
      $('.menu.users').remove()
      $('.menu.settings').removeClass('hidden')
    ), 500
    
    setTimeout (->
      $('.spaceFrame').remove()
    ), 1000 # duration of animation
