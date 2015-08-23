mouse = { x: null, y: null }
click = { x: null, y: null }

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

x = ($) ->
  currTrans = $.css('transform').split(/[()]/)[1]
  currTrans.split(',')[4]

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  
  card_container.init.call $('.slidingContainer')
  
  $(window).scroll (event) ->
    if window.dontScroll is true
      window.dontScroll = false
    else
      card_container.scroll.call $('.slidingContainer')

  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()
    
  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

  # open a collection
  $('.cover').click () ->
    return if $(@).hasClass 'open'

    cover = $(@)
    spacekey = cover.data('spacekey')
    
    $('.open').removeClass 'open'
    cover.addClass 'open'

    # window.oldWidth = $(window.document).width()
    # window.oldScroll = $(window).scrollLeft()
    
    $(window).scrollLeft 0
    cover.siblings().hide()

    content = cover.children('.collectionContent').children()
    content.addClass spacekey
    content.insertAfter $(@)
    
    content.velocity {translateX: x(cover), opacity:0}, {duration:0 }
    content.velocity {opacity: 1}, {duration:1000 }

    animateOptions =
      duration: 1000
      opacity: 1.0

    card_container.realign.call $('.slidingContainer'), animateOptions

  window.onpopstate = (event) ->
    return unless $('.open').length

    cover = $('.open')
    cover.removeClass 'open'

    spacekey = cover.data 'spacekey'
    
    content = $(".#{spacekey}").not(".cover")

    content.appendTo cover.children(".collectionContent")

    cover.siblings().show()
    # $(window.document).css 'width', window.oldWidth
    # $(window).scrollLeft window.oldScroll
    
    animateOptions =
      duration: 1000
      opacity: 1.0
    card_container.realign.call $('.slidingContainer'), animateOptions