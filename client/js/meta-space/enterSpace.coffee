scaleMultiple = 2

$ ->
  # $('.metaspace').css("transform", "scale3d(0.5, 0.5, 1.0)")
  window.userSettings = $('ul.menu.right.settings')
  $('.spacePreview').not('.add').click () ->
    spaceKey = $(@).data().spaceid
    history.pushState {name: "/s/#{spaceKey}"}, "", "/s/#{spaceKey}"
    enterSpace spaceKey, $(@)
  
enterSpace = (spaceKey, parent, callback) ->
  url = window.location.origin+"/r/"+spaceKey
  
  offsetLeft = 1 # pixel adjustment
  offsetTop  = $(window).scrollTop() - parent.offset().top*2 - 5 # pixel adjustment

  #Take the name from the home page view and hide it.
  

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
    
    parent.addClass("open")
    $('.metaspace').
      addClass('open').
      removeClass('closed').
      css("transform", "scale3d(1.0, 1.0, 1.0)")
    $(".content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")
    $('ul.menu.settings').addClass('hidden')
    $('h1.logo').addClass('hidden')
    $('.container > header').append($("iframe").contents().find('.users.menu'))
    $('.users.menu').removeClass('hidden')
    $('header > a.back').removeClass('hidden')

     
    setTimeout () ->
      homeSpaceName = parent.find('.spaceName').hide()
      $(".spacePreview").not(parent).addClass("hidden")
      $('.headerSpaceName').show().text homeSpaceName.text()  
    , 1000

    callback() if callback 
    $('.spaceForm').submit (e) ->    
      e.preventDefault()   
      newName = $(@).find(':input').val()    
      $.post '/s/update', { spaceKey, name: newName }    
      $('.headerSpaceName').show().text newName    
      homeSpaceName.text newName   
      $(@).hide()
