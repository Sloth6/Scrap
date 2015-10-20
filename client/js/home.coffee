defaultCurve            = 'easeOutExpo'
openCollectionCurve     = [50, 8]
openCollectionDuration  = 1000

margin = $(window).width() / 96
sliderBorder = () -> $(window).width() / 6
edgeWidth = 48

click = { x: null, y: null }
window.pastState = { docWidth: null, scrollLeft: null }

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

xForceFeedSelf = () ->
  xTransform $(@)

xTransform = (elem) ->
  transform = elem.css('transform')
  new WebKitCSSMatrix(transform).e

yTransform = (elem) ->
  transform = elem.css('transform')
  new WebKitCSSMatrix(transform).f

$ ->
  window.socket = io.connect()
  window.openSpace = "home"
  history.pushState { name: "home" }, "", "/"

  window.container = $('.slidingContainer')
  
  collectionRealign { animate: false }
  
  $.Velocity.defaults.duration = openCollectionDuration
  $.Velocity.defaults.easing = openCollectionCurve
  $.Velocity.defaults.queue = false

  collectionOpen $('.cover.root'), {}, () ->
    hyphenateText()
  # Main scroll event
  $(window).scroll (event) ->
    collectionScroll.call $('.slidingContainer')
    $('.hover').removeClass 'hover'

  # Enable the user to scroll vertically and map it to horizontal scroll
  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()

  # sliderInit $('.slider')

  # Close a collection on page back
  window.onpopstate = (event) ->
    # event.state.name will either be 'home' or a spaceKey
    # spaceKey = event.state.name
    # window.openSpace = spaceKey    
    # always close any open collection first
    if $('.cover.open').length
      collectionClose()
    
    # equivlant to if spaceKey != home and spacekey cover exists
    # if $(".cover.#{spaceKey}").length
    #   collectionOpen $(".cover.#{spaceKey}")