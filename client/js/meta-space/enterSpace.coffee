scaleMultiple = 2

$ ->
  window.userSettings = $('ul.menu.right.settings')
  $('.spacePreview').not('.add').click () ->
    spaceKey = $(@).data().spaceid
    history.pushState {name: "/s/#{spaceKey}"}, "", "/s/#{spaceKey}"
    enterSpace spaceKey, $(@)

scrollToSpace = (parent) ->
  offsetLeft = 0
  offsetTop  = $(window).scrollTop() - parent.offset().top*2

  $('.metaspace').
    addClass('open').
    removeClass('closed').
    css("transform", "scale3d(1.0, 1.0, 1.0)")
  $(".content").css("transform", "translate3d(" + offsetLeft + "px, " + offsetTop + "px, 0px)")

enterSpace = (spaceKey, parent, callback) ->
  url = window.location.origin+"/r/"+spaceKey
  scrollToSpace parent
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
  css({ width: '100vw', height: '100vh' }).
  appendTo($('.container')).
  load () ->
    $('ul.menu.settings').addClass('hidden')
    $('h1.logo').addClass('hidden')
    $('.container > header').append($("iframe").contents().find('.users.menu'))
    $('.users.menu').removeClass('hidden')
    $('header > a.back').removeClass('hidden')

    setTimeout (() =>
      $('.metaspace').hide()
      $(document.body).css overflow: 'hidden'
      homeSpaceName = parent.find('.spaceName').hide()
      $(".spacePreview").not(parent).addClass("hidden")
      $('.headerSpaceName').show().text homeSpaceName.text()        
    ), 400

    callback() if callback 
    # $('.spaceForm').submit (e) ->    
    #   e.preventDefault()   
    #   newName = $(@).find(':input').val()    
    #   $.post '/s/update', { spaceKey, name: newName }    
    #   $('.headerSpaceName').show().text newName    
    #   homeSpaceName.text newName   
    #   $(@).hide()
