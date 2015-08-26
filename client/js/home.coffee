defaultCurve            = 'easeOutExpo'
openCollectionCurve     = [500, 100]
openCollectionDuration  = 1000
margin = 0

mouse = { x: null, y: null }
click = { x: null, y: null }
window.pastState = { docWidth: null, scrollLeft: null }


randomColor = ->
  letters = '0123456789ABCDEF'.split('')
  color = '#'
  i = 0
  while i < 6
    color += letters[Math.floor(Math.random() * 16)]
    i++
  color

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

xTransform = ($) ->
  transform = $.css('transform')
  new WebKitCSSMatrix(transform).e

yTransform = ($) ->
  transform = $.css('transform')
  new WebKitCSSMatrix(transform).f

open = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  elements = collectionContent.children 'article'
  spacekey = cover.data 'spacekey'
  cover.removeClass 'sliding'
  cover.css { 'position': 'absolute', 'zIndex': 999}

  history.pushState { name: "home" }, "", "/#{spacekey}"

  # Close anything else thats open
  $('.open').removeClass 'open'
  collection.removeClass('closed').addClass 'open'

  # Remember where we were
  window.pastState.scrollLeft = $(window).scrollLeft()
  window.pastState.docWidth   = $(window.document).width()

  cover_position = xTransform(cover)


  # collection.siblings().velocity
  #   properties:
  #     opacity: [0, 1]
  #   options:
  #     duration:   500
  #     # easing:     openCollectionCurve
      # complete: () ->
  $(window).scrollLeft 0
  collection.siblings().hide()

  collectionContent.show()
  
  elements.css { x: xTransform(cover) }


  cover.velocity
    properties:
      translateX: [- cover.width() + 50,  cover_position]
    options:
      duration: openCollectionDuration
      queue: false
      easing:openCollectionCurve

  collectionContent.velocity
    properties:
      opacity: [1, 0]
    options:
      duration: openCollectionDuration
      easing: openCollectionCurve

  card_container.realign.call $('.slidingContainer')

close = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  elements = collectionContent.children 'article'
  spacekey = cover.data 'spacekey'
  
  # 
  cover.addClass 'sliding'

  collection.removeClass('open').addClass 'closed'
  collection.siblings().show()
  
    # elements to remove
  collectionContent.children().css 'zIndex', 0
  collectionContent.hide()

  $(window).scrollLeft window.pastState.scrollLeft
  $(document.body).css width: window.pastState.docWidth
  card_container.realign_dont_scale.call $('.slidingContainer')

  $("body").css("overflow", "hidden")
  setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration

  collection.siblings().velocity
    properties:
      opacity: [1, 0]
    options:
      duration:   openCollectionDuration
      easing:     openCollectionCurve


  # padding = $('<div>').addClass('padding').addClass('sliding').css('width', $('.cover').width())
  # collectionContent.append padding

  

  
  # collectionContent.css 'opacity', 1

  # collectionContent.velocity
  #   properties:
  #     translateZ: 0
  #     opacity:    0
  #   options:
  #     duration:   openCollectionDuration
  #     easing:     openCollectionCurve
  #     complete: () ->
  #       collectionContent.hide()
  #       collectionContent.css 'opacity', 1
  #       collectionContent.children().removeClass 'collapsing'
  #       cover.removeClass 'collapsing'
  #       padding.remove()

  # elements.velocity
  #   properties:
  #     translateZ: 0
  #     translateY: 0
  #     translateX: 0
  #     rotateZ:    0
  #   options:
  #     duration:   openCollectionDuration
  #     easing:     openCollectionCurve
  


#         $(@).velocity({
#                 rotateZ : 0
#         }, {
#                 duration : openCollectionDuration,
#                 easing : openCollectionCurve
#         })

#         $elements.velocity({
#                 rotateZ : 0
#                 translateY : 0;
#         }, {
#                 duration : openCollectionDuration,
#                 easing : openCollectionCurve
#         })

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  
  card_container.realign.call $('.slidingContainer'), false
  
  $(window).scroll (event) ->
    # if $('.velocity-animating').length
    #   console.log 'true'
    #   event.preventDefault()
    #   return false
    card_container.scroll.call $('.slidingContainer')

  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()
    
  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY
    
  $('header.cover .card').each( () ->
    $(@).css({
      backgroundColor : randomColor
    })
  )
  
  # $('.cover, article').mouseenter () ->
  #   $(@).velocity({
  #       rotateZ : 0
  #   }, {
  #       duration : 250,
  #       easing : defaultCurve
  #   })
  
  # $('.cover, article').mouseleave () ->
  #   $(@).velocity({
  #       rotateZ : (Math.random() * 8) + (Math.random() * -8)
  #   }, {
  #       duration : 250,
  #       easing : defaultCurve
  #   })
  
  # open a collection
  $('.cover').click () ->
    return if $(@).hasClass 'open'
    open $(@)

  window.onpopstate = (event) ->
    return unless $('.open').length

    cover = $('.open').children '.cover'
    close cover