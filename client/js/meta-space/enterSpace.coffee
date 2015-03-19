$ -> 
  elements = $('.draggable')
  elements.click () ->
    url = window.location+"s/"+$(@).data().spaceid
    $(@).css 'transform-origin', '0% 0%'
    $(@).zIndex 100

    $('<iframe />', {
      name: 'spaceFrame'
      id:   'spaceFrame'
      src: url
    }).
    css({
      top: 0
      left: 0
      "transform-origin": '0% 0%'
      position: 'relative'
      width: $(window).width()#'100%'
      height: $(window).height()#'100%'
      scale: Math.min(300 / $(window).width(), 200 / $(window).height())
    }).
    click((event)->
      event.preventDefault()
      event.stopPropagation()
    ).
    prependTo($(@)).
    ready () =>
      setTimeout(() =>

        $('#home').show()
        $(@).children('iframe').animate { scale: 1 }, 500
        $(@).animate({
          'border-width': 0
          top: 0
          left: 0
          width: $(window).width()
          height: $(window).height()
        }, 500)
      ,500)
    
