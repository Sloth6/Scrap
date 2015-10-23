defaultCurve            = 'easeOutExpo'
openCollectionCurve     = [50, 8]
openCollectionDuration  = 1000

marginTop = $(window).height() * 0.15
margin = $(window).width() / 48
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

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  window.container = $('.slidingContainer')
  
  $.Velocity.defaults.duration = openCollectionDuration
  $.Velocity.defaults.easing = openCollectionCurve
  $.Velocity.defaults.queue = false

  console.log $('.cover.root')
  collectionOpen $('.cover.root')

  # Main scroll event
  $(window).scroll (event) ->
    collectionScroll.call $('.slidingContainer')
    $('.hover').removeClass 'hover'

  # Enable the user to scroll vertically and map it to horizontal scroll
  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()


  $('.backButton').click (event) ->
    event.preventDefault()
    history.back()

  # Close a collection on page back
  window.onpopstate = (event) ->
    throw 'No event state object' unless event.state
    # close the open collection and return the view to where it was 
    # when it was opened. which is stored in the state object
    if $('.cover.open, .stack.open').length
      collectionClose({ state: event.state })
