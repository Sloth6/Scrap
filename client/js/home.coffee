defaultCurve            = 'easeOutExpo'
openCollectionCurve     = [20, 10]
openCollectionDuration  = 1000
margin = 50
sliderBorder = () -> $(window).width() / 4
edgeWidth = 64

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

xForceFeedSelf = () ->
  xTransform $(@)

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
  
  $.Velocity.defaults.duration = openCollectionDuration
  $.Velocity.defaults.easing = openCollectionCurve
  $.Velocity.defaults.queue = false

  # Main scroll event
  $(window).scroll (event) ->
    collectionScroll.call $('.slidingContainer')

  # Enable the user to scroll vertically and map it to horizontal scroll
  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()


  $('.slider').each sliderJumble

  $('.slider').mouseover( () ->
    return unless $(@).hasClass('sliding')
    x = xTransform($(@))
    return if x < edgeWidth or (x > $(window).width - edgeWidth)

    $(@).data 'oldZIndex', $(@).css('zIndex')
    $(@).css 'zIndex', collectionChildren.call($('.slidingContainer')).length + 1
  ).mouseout () ->
    $(@).data('oldZIndex') and $(@).css 'zIndex', $(@).data('oldZIndex')

  # Close a collection on page back
  window.onpopstate = (event) ->
    console.log 'onpopstate'
    return unless $('.open').length
    cover = $('.open').children '.cover'
    collectionClose cover

  $('header.cover .card').each () ->
    $(@).css { backgroundColor : randomColor }
