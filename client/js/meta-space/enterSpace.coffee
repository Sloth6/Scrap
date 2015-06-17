scaleMultiple = 2

$ ->
  window.userSettings = $('ul.menu.right.settings')
  $('.spacePreview').not('.add').click () ->
    spaceKey = $(@).data().spaceid
    history.pushState {name: "/s/#{spaceKey}"}, "", "/s/#{spaceKey}"
    enterSpace spaceKey, $(@)
  
enterSpace = (spaceKey, parent, callback) ->
  url = window.location.origin+"/r/"+spaceKey
  
  scrollTop     = $(window).scrollTop()
  elementOffsetTop     = parent.offset().top
  distanceTop   = (elementOffsetTop - scrollTop)

  scrollLeft     = $(window).scrollLeft()
  elementOffsetLeft     = parent.offset().left
  distanceLeft   = (elementOffsetLeft - scrollLeft)

  offsetLeft = 0 # parseFloat -(distanceLeft + $('.metaspace').width())
  offsetTop  = parseFloat -distanceTop

  console.log offsetLeft
  console.log offsetTop
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
  load () ->
    $('.home').show()
    $(".spacePreview").not(parent).addClass("hidden")
    parent.addClass("open")
    $('.metaspace').
      addClass('open').
      removeClass('closed').
      css("transform", "scale3d(1.0, 1.0, 1.0)")
#     $(".content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")
    $(".content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")
    $('ul.menu.settings').addClass('hidden')
    $('h1.logo').addClass('hidden')
    $('.container > header').append($("iframe").contents().find('.users.menu'))
    $('.users.menu').removeClass('hidden')
    $('header > a.back').removeClass('hidden')

    $('.headerSpaceName').show().text homeSpaceName.text()   
    callback() if callback   
    $('.spaceForm').submit (e) ->    
      e.preventDefault()   
      newName = $(@).find(':input').val()    
      $.post '/s/update', { spaceKey, name: newName }    
      $('.headerSpaceName').show().text newName    
      homeSpaceName.text newName   
      $(@).hide()
