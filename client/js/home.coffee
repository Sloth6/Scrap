openCollectionCurve     = [20, 10]
openCollectionDuration  = 1000
defaultCurve            = [20, 10]
defaultDuration         = 500
bouncyCurve             = [100, 10]
fastDuration            = 250

marginTop       = $(window).height() * 0.125
articleMargin   = 24
packMargin      = 72
sliderBorder    = $(window).width() * 0.15
edgeWidth       = 48
marginAfter     = $(window).width()/2

collectionPath = []

history.scrollRestoration = 'manual'

# Main scroll event
onScroll = ->
  return if $('.velocity-animating').length
  # console.log 'on scrolla', $(window).scrollLeft()
  collectionViewController.draw $('.open.collection')
  $('.hover').removeClass 'hover'
  # console.log 'on scrollb', $(window).scrollLeft()

# Enable the user to scroll vertically and map it to horizontal scroll
onMousewheel = (event) ->
  return false if $('.velocity-animating').length
  if Math.abs(event.deltaY) > Math.abs(event.deltaX)
    $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
    event.preventDefault()

# Close the open collection.
window.onpopstate = (event) -> 
  throw 'No event state object' unless event.state
  event.preventDefault()
  navigationController.close $('.collection.open'), event.state
  
$ ->
  window.socket = io.connect()
  
  $.Velocity.defaults.duration = openCollectionDuration
  $.Velocity.defaults.easing   = openCollectionCurve
  $.Velocity.defaults.queue    = false

  $('.slidingContainer').css y: marginTop

  onScroll()
  $(window).scroll onScroll
  $(window).resize onScroll
  $(window).mousewheel onMousewheel

  # Trigger the history back event.
  $('.backButton').click (event) ->
    event.preventDefault()
    history.back()
    
  footerController.init $('footer.main')
  navigationController.open $('.collection.root')

