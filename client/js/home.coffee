defaultCurve            = 'easeOutExpo'
openCollectionCurve     = [500, 100]
openCollectionDuration  = 4000
margin = -2
sliderBorder = () -> $(window).width() / 6
edgeWidth = 30

click = { x: null, y: null }
window.pastState = { docWidth: null, scrollLeft: null }

randomColor = ->
  letters = '0123456789ABCDEF'.split('')
  color = '#'
  i = 0
  while i < 6
    color += letters[Math.floor(((Math.random() / 2) + .5) * 16)]
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

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  
  collectionRealign.call $('.slidingContainer'), false
  
  # Main scroll event
  $(window).scroll (event) ->
    collectionScroll.call $('.slidingContainer')

  # Enable the user to scroll vertically and map it to horizontal scroll
  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()

  # Open a collection on click
  $('.cover').click () ->
    return if $(@).hasClass 'open'
    collectionOpen $(@)

  # $('.sliding').not('.cover').each sliderJumble
# 
  # $('.cover').each () ->
  #   $(@).data('translateY', 0)
  #   $(@).data('rotateZ', 0)

  $('.sliding').mouseover( () ->
    return unless $(@).hasClass('sliding')
    $(@).data 'oldZIndex', $(@).css('zIndex')
    $(@).css 'zIndex', collectionChildren.call($('.slidingContainer')).length + 1
  ).mouseout () ->
    return unless $(@).hasClass('sliding')
    $(@).data('oldZIndex') and $(@).css 'zIndex', $(@).data('oldZIndex')

  # Close a collection on page back
  window.onpopstate = (event) ->
    return unless $('.open').length
    cover = $('.open').children '.cover'
    collectionClose cover

  $('header.cover .card').each () ->
    $(@).css { backgroundColor : randomColor }
  
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