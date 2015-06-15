scaleMultiple = 2

$ ->
  window.userSettings = $('ul.menu.right.settings')
  elements = $('.spacePreview').not('.add')
  elements.click () ->
    spaceKey = $(@).data().spaceid
    history.pushState {name: "/s/#{spaceKey}"}, "", "/s/#{spaceKey}"
    enterSpace spaceKey, $(@)
  
enterSpace = (spaceKey, parent, callback) ->
  url = window.location.origin+"/r/"+spaceKey

  offsetLeft = parseFloat -(parent.offset().left * scaleMultiple) + $('.content').width()/4  - (parent.width()  * .0635)
  offsetTop  = parseFloat -(parent.offset().top  * scaleMultiple) + $('.content').height()/4 - (parent.height() * .0635)

  #Take the name from the home page view and hide it.
  homeSpaceName = parent.find('.spaceName').hide()

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

    , 500)
    
    setTimeout(() ->
      $('.container > header').append($("iframe").contents().find('.users.menu'))
#       window.userSettings.remove()
    , 600)
    
    setTimeout(() ->
      $('.users.menu').removeClass('hidden')
      $('a.back').removeClass('hidden')
    , 700)