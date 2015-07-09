scaleMultiple = 2

$ ->
  window.userSettings = $('ul.menu.right.settings')
  $('.spacePreview').not('.add').click () ->
    $(@).find('.iframeBlocker').css {width:0, height: 0}
    spaceKey = $(@).data().spaceid
    history.pushState {name: "/s/#{spaceKey}"}, "", "/s/#{spaceKey}"
    enterSpace $(@), $(@).find('iframe'), spaceKey
  
enterSpace = (preview, iframe, spaceKey) ->
  # url = window.location.origin+"/r/"+spaceKey
  offsetLeft = -16 # pixel adjustment
  offsetTop  = $(window).scrollTop() - preview.offset().top*scaleMultiple - 16 # pixel adjustment


  #Take the name from the home page view and hide it.
  $('.home').show()
  preview.addClass("open")
  $('.metaspace').
    addClass('open').
    removeClass('closed').
    css("transform", "scale3d(1.0, 1.0, 1.0)")
  $(".content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")
  $('ul.menu.settings').addClass('hidden')
  $('h1.logo').addClass('hidden')

  $('.container > header').append iframe.contents().find('.users.menu')

  $('.users.menu').removeClass('hidden')
  $('header > a.back').removeClass('hidden')

  $(".menu,h1,a").bind "mousewheel", () -> return false
  setTimeout () ->
    homeSpaceName = preview.find('.spaceName').hide()
    $(".spacePreview").not(preview).addClass("hidden")
    $('.headerSpaceName').show().text homeSpaceName.text()
  , 1000

  # callback() if callback 
  # $('.spaceForm').submit (e) ->    
  #   e.preventDefault()   
  #   newName = $(@).find(':input').val()    
  #   $.post '/s/update', { spaceKey, name: newName }    
  #   $('.headerSpaceName').show().text newName    
  #   homeSpaceName.text newName   
  #   $(@).hide()
