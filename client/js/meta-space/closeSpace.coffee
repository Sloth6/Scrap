closeSpace = () ->
  $('.metaspace').show()
  $(document.body).css('overflow', 'visible')

  openSpace = $('.spacePreview.open')
  openSpace.find('.iframeBlocker').css {width:'100%', height: '100%'}
  
  if $('.spaceForm').is(":visible")
    $('.spaceForm').trigger('submit')
  
  # update the url  
  $('.container > header').append window.userSettings
  $('.menu.settings').addClass 'hidden'
  $('.metaspace')
    .addClass 'closed'
    .removeClass 'open'
    .css "transform", "translate(0px, 0px)"

  $(".content").css("transform", "scale("+(1.0/scaleMultiple)+","+ (1.0/scaleMultiple)+")")
  $(".spacePreview").not($(this)).removeClass("hidden")
  $(".spacePreview").removeClass('open')
  $('a.back').addClass('hidden')
  $('.menu.users').addClass('hidden')
  
  #  The chrome gods are angry, this sacrifical pixel pleases them
  $(window).scrollTop($(window).scrollTop()+1)
  
  setTimeout (->
    $('h1.logo').removeClass('hidden')
    $('.menu.users').remove()
    $('.menu.settings').removeClass('hidden')
    openSpace.find('.spaceName').text($('.headerSpaceName').text()).show()
    $('.headerSpaceName').hide()
  ), 500