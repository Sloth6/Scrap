$ ->    
  $('.back').click (event) ->
    event.preventDefault()

        #update the url
    bg = $('.spacePreview.open').css 'background-image'
    bg = bg.replace('url(','').replace(')','')
    url = bg+'?'+(new Date().getTime())
    $('.spacePreview.open').css 'background-image', 'url('+url+')'


    $('.container > header').append(window.userSettings)
    $('.menu.settings').addClass('hidden')
    
    $('.metaspace').addClass('closed');
    $('.metaspace').removeClass('open');
    $(".metaspace").css("transform", "translate3d(0px, 0px, 0px)");
    $(".metaspace > section.content").css("transform", "scale3d("+1.0/scaleMultiple+","+ 1.0/scaleMultiple+","+ 1.0+")")
    $(".spacePreview").not($(this)).removeClass("hidden")
    $(".spacePreview").removeClass('open');
    $('a.back').addClass('hidden')
    $('.menu.users').addClass('hidden')

    setTimeout (->
      $('h1.logo').removeClass('hidden')
      $('.menu.users').remove()
      $('.menu.settings').removeClass('hidden')
    ), 500
    
    setTimeout (->
      $('.spaceFrame').remove()
    ), 1000 # duration of animation
