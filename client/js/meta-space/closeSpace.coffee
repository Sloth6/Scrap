closeSpace = () ->
  $('.spaceFrame').remove()
  $('.metaspace').show()
  $(document.body).css('overflow', 'visible')

  openSpace = $('.spacePreview.open')
  
  if $('.spaceForm').is(":visible")
    $('.spaceForm').trigger('submit')
  
  # update the url
  bg = $('.spacePreview').not('.hidden').css 'background-image'
  console.log bg
  if bg
    # new spaces will  not have image
    bg = bg.replace('url(','').replace(')','').split('?')[0]
    url = bg+'?'+(new Date().getTime())
    $('.spacePreview').not('.hidden').css 'background-image', 'url('+url+')'
  
  $('.container > header').append(window.userSettings)
  $('.menu.settings').addClass('hidden')
  
  $('.metaspace')
    .addClass('closed')
    .removeClass('open')
    .css("transform", "translate3d(0px, 0px, 0px)");
  $(".metaspace > section.content").css("transform", "scale3d("+1.0/scaleMultiple+","+ 1.0/scaleMultiple+","+ 1.0+")")
  $(".spacePreview").not($(this)).removeClass("hidden")
  $(".spacePreview").removeClass('open')
  $('a.back').addClass('hidden')
  $('.menu.users').addClass('hidden')

  setTimeout (->
    $('h1.logo').removeClass('hidden')
    $('.menu.users').remove()
    $('.menu.settings').removeClass('hidden')
    openSpace.find('.spaceName').text($('.headerSpaceName').text()).show()
    $('.headerSpaceName').hide()
  ), 500