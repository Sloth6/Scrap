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

  sliderInit $('.slider')

  # Close a collection on page back
  window.onpopstate = (event) ->
    # event.state.name will either be 'home' or a spaceKey
    spaceKey = event.state.name

    # always close any open collection first
    if  $('.cover.open').length
      collectionClose $('.cover.open')
    
    # equivlant to if spaceKey != home and spacekey cover exists
    if $(".cover.#{spaceKey}").length
      collectionOpen $(".cover.#{spaceKey}")

  $('header.cover .card.colored').each () ->
    $(@).css { backgroundColor : randomColor }