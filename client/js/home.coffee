openCollectionCurve     = [20, 10]
openCollectionDuration  = 1000
defaultCurve            = [20, 10]
defaultDuration         = 500

marginTop    = $(window).height() * 0.125
margin       = 32
sliderBorder = $(window).width() * 0.15
edgeWidth    = 48
marginAfter  = $(window).width()/2

collectionPath = []

# Main scroll event
onScroll = ->
  return if $('.velocity-animating').length
  collectionViewController.draw $('.open.collection')
  $('.hover').removeClass 'hover'

# Enable the user to scroll vertically and map it to horizontal scroll
onMousewheel = (event) ->
  return false if $('.velocity-animating').length
  if Math.abs(event.deltaY) > 2
    $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
    event.preventDefault()

# Close the open collection.
window.onpopstate = (event) -> 
  throw 'No event state object' unless event.state
  navigationController.close $('.collection.open'), event.state

$ ->
  window.socket = io.connect()
  
  $.Velocity.defaults.duration = openCollectionDuration
  $.Velocity.defaults.easing   = openCollectionCurve
  $.Velocity.defaults.queue    = false

  #TODO reimpelment this
  #, {}, () -> hyphenateText()
  $('.slidingContainer').css y: marginTop
  # $('.content').css y: marginTop
  # $('.content').velocity { translateY: marginTop}, {duration: 1}
  
  onScroll()
  $(window).scroll onScroll
  $(window).resize onScroll
  $(window).mousewheel (event) -> onMousewheel(event)

  # Trigger the history back event.
  $('.backButton').click (event) ->
    event.preventDefault()
    history.back()
    
  footerController.init $('footer.main')

  # history.pushState { name: "home" }, "", "/"

  navigationController.open $('.collection.root')


