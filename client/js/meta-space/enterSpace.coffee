scaleMultiple   = 3

$ ->
  window.userSettings = $('ul.menu.right.settings')
  elements = $('.draggable')
  elements.click () ->
    url = window.location+"s/"+$(@).data().spaceid
    offsetLeft      = parseFloat -($(this).offset().left * scaleMultiple) + $('.metaspace').width()/scaleMultiple  - ($(this).width()  * .1275)
    offsetTop       = parseFloat -($(this).offset().top  * scaleMultiple) + $('.metaspace').height()/scaleMultiple - ($(this).height() * .1285)

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
        $(".spacePreview").not($(this)).addClass("hidden")
        $(this).addClass("open")
        $('.metaspace').addClass('open')
        $('.metaspace').removeClass('closed')
        $(".metaspace > section.content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")
        $(".metaspace").css("transform", "scale3d(1.0, 1.0, 1.0)")
        $('ul.menu.settings').addClass('hidden')
        $('h1.logo').addClass('hidden')
      , 500)
      
      setTimeout(() ->
        $('.container > header').append($("iframe").contents().find('.users.menu'))
        window.userSettings.remove()
      , 600)
      
      setTimeout(() ->
        $('.users.menu').removeClass('hidden')
        $('a.back').removeClass('hidden')
      , 700)