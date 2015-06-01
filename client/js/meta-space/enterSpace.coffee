scaleMultiple   = 3

$ -> 
  elements = $('.draggable')
  elements.click () ->
    url = window.location+"s/"+$(@).data().spaceid
    offsetLeft      = parseFloat -($(this).offset().left * scaleMultiple) + $('.metaspace').width()/scaleMultiple
    offsetTop       = parseFloat -($(this).offset().top  * scaleMultiple) + $('.metaspace').height()/scaleMultiple

    $('<iframe />', {
      name: 'spaceFrame'
      class:'spaceFrame'
      src: url
    }).
    click((event)->
      event.preventDefault()
      event.stopPropagation()
    ).
    prependTo($(@)).
    ready () =>
      setTimeout(() =>
        $('.home').show()
#         $(".draggable").not($(this)).addClass("hidden")
        $(@).addClass("open")
        $('.metaspace').addClass('open')
        $('.metaspace').removeClass('closed')
        $(".metaspace").css("transform", "scale3d(1, 1, 1) translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)");
        console.log         "transform", "scale3d(1, 1, 1) translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)"
      , 500)    
