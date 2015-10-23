defaultCurve            = 'easeOutExpo'
smoothCurve             = [20, 10]
openCollectionCurve     = smoothCurve # [50, 8]
openCollectionDuration  = 1000

marginTop = $(window).height() * 0.125
margin = 16
coverMargin = 120
sliderBorder = () -> $(window).width() / 6
edgeWidth = 48

click = { x: null, y: null }
window.pastState = { docWidth: null, scrollLeft: null }

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

Array.prototype.last = () ->
  @[@length - 1]

xForceFeedSelf = () ->
  xTransform $(@)

xTransform = (elem) ->
  transform = elem.css('transform')
  new WebKitCSSMatrix(transform).e

yTransform = (elem) ->
  transform = elem.css('transform')
  new WebKitCSSMatrix(transform).f

spacePath = []

# Main scroll event
onScroll = ->
  collectionScroll.call $('.slidingContainer')
  $('.hover').removeClass 'hover'

# Enable the user to scroll vertically and map it to horizontal scroll
onMousewheel = (event) ->
  if Math.abs(event.deltaY) > 2
    $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
    event.preventDefault()

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  window.container = $('.slidingContainer')
  
  $.Velocity.defaults.duration = openCollectionDuration
  $.Velocity.defaults.easing = openCollectionCurve
  $.Velocity.defaults.queue = false

  collectionOpen $('.cover.root'), {}, () ->
    hyphenateText()
    
  onScroll()
  $(window).scroll(onScroll)
  $(window).resize(onScroll)
  $(window).mousewheel (event) -> onMousewheel(event)

  # Close a collection on page back
  window.onpopstate = (event) ->
    # event.state.name will either be 'home' or a spaceKey
    # spaceKey = event.state.name
    # always close any open collection first
    if $('.cover.open, .stack.open').length
      collectionClose()
