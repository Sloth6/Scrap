scaleMultiple   = 3

$ ->
  window.userSettings = $('ul.menu.right.settings')
  elements = $('.spacePreview').not('.new')
  elements.click () ->
    enterSpace $(@).data().spaceid, $(@)

enterSpace = (spaceId, parent) ->
  url = window.location+"s/"+spaceId
  offsetLeft = parseFloat -(parent.offset().left * scaleMultiple) + $('.metaspace').width()/scaleMultiple  - (parent.width()  * .1275)
  offsetTop  = parseFloat -(parent.offset().top  * scaleMultiple) + $('.metaspace').height()/scaleMultiple - (parent.height() * .1285)

  $('<iframe />', {
    name: 'spaceFrame'
    class:'spaceFrame'
    src: url
  }).
  click((event)->
    event.preventDefault()
    event.stopPropagation()
  ).
  prependTo(parent).
  ready () =>
    setTimeout(() =>
      $('.home').show()
      $(".spacePreview").not(parent).addClass("hidden")
      parent.addClass("open")
      $('.metaspace').addClass('open')
      $('.metaspace').removeClass('closed')
      $(".metaspace > section.content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")
      $(".metaspace").css("transform", "scale3d(1.0, 1.0, 1.0)")
      $('ul.menu.settings').addClass('hidden')
      $('h1.logo').addClass('hidden')
      history.pushState {name: "/s/#{spaceId}"}, "", "/s/#{spaceId}"
    , 500)
    
    setTimeout(() ->
      $('.container > header').append($("iframe").contents().find('.users.menu'))
      window.userSettings.remove()
    , 600)
    
    setTimeout(() ->
      $('.users.menu').removeClass('hidden')
      $('a.back').removeClass('hidden')
    , 700)