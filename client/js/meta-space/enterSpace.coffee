scaleMultiple = 3

$ ->
  window.userSettings = $('ul.menu.right.settings')
  elements = $('.spacePreview').not('.add')
  
  $('.headerSpaceName').click () ->
    $('.headerSpaceName').hide()
    $('.spaceForm').show()
    $('.spaceForm :input').val $('.headerSpaceName').text()

  elements.click () ->
    enterSpace $(@).data().spaceid, $(@)
  
enterSpace = (spaceKey, parent) ->
  url = window.location+"r/"+spaceKey
  offsetLeft = parseFloat -(parent.offset().left * scaleMultiple) + $('.metaspace').width()/scaleMultiple  - (parent.width()  * .1275)
  offsetTop  = parseFloat -(parent.offset().top  * scaleMultiple) + $('.metaspace').height()/scaleMultiple - (parent.height() * .1285)
  
  #Take the name from the home page view and hide it.
  homeSpaceName = parent.find('.spaceName').hide()

  #Create the iframe
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
      history.pushState {name: "/s/#{spaceKey}"}, "", "/s/#{spaceKey}"
    , 500)
    
    setTimeout(() ->
      $('.container > header').append($("iframe").contents().find('.users.menu'))
      window.userSettings.remove()

      $('.users.menu').removeClass('hidden')
      $('a.back').removeClass('hidden')


      $('.headerSpaceName').show().text homeSpaceName.text()

      $('.spaceForm').submit (e) ->
        e.preventDefault()
        newName = $(@).find(':input').val()
        $.post '/s/update', { spaceKey, name: newName }

        $('.headerSpaceName').show().text newName
        homeSpaceName.text newName
        $(@).hide()
    , 700)