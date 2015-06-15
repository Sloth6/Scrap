$ ->
  history.pushState {name: "metaspace"}, "", "/"

  window.onpopstate = (event) ->
    page = event.state.name
    if page is 'metaspace'
      closeSpace()

  $('.back').click (event) ->
    event.preventDefault()
    closeSpace()
    history.back()

closeSpace = () ->
  openSpace = $('.spacePreview.open')
  
  if $('.spaceForm').is(":visible")
    $('.spaceForm').trigger('submit')
  
  # update the url
  bg = $('.spacePreview.open').css 'background-image'
  
  if bg
    # new spaces will  not have image
    bg = bg.replace('url(','').replace(')','')
    url = bg+'?'+(new Date().getTime())
    $('.spacePreview.open').css 'background-image', 'url('+url+')'
  
  $('.container > header').append(window.userSettings)
  $('.menu.settings').addClass('hidden')
  
  $('.metaspace').addClass('closed')
  $('.metaspace').removeClass('open')
  $(".metaspace").css("transform", "translate3d(0px, 0px, 0px)");
  $(".metaspace > section.content").css("transform", "scale3d("+1.0/scaleMultiple+","+ 1.0/scaleMultiple+","+ 1.0+")")
  $(".spacePreview").not($(this)).removeClass("hidden")
  $(".spacePreview").removeClass('open')
  $('a.back').addClass('hidden')
  $('.menu.users').addClass('hidden')



  setTimeout (->
    $('h1.logo').removeClass('hidden')
#     $('.menu.users').remove()
    $('.menu.settings').removeClass('hidden')
    openSpace.find('.spaceName').text($('.headerSpaceName').text()).show()
    $('.headerSpaceName').hide()

  ), 500
  setTimeout (->
    $('.spaceFrame').remove()
  ), 1000