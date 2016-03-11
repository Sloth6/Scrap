Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

Array.prototype.last = () -> @[@length - 1]

window.xTransform = ($element) ->
  parseFloat $.Velocity.hook($element, 'translateX')

window.yTransform = ($element) ->
  parseFloat $.Velocity.hook($element, 'translateY')

window.getRotateZ = ($element) ->
  parseFloat $.Velocity.hook($element, 'rotateZ')

window.logisticFunction = (x) ->
  1 / (1 + Math.pow(Math.E, -x))

# Return type of pointer event
window.pointerType = (event) ->
  if event.type.indexOf('mouse') >= 0
    return 'mouse'
  else if event.type.indexOf('touch') >= 0
    return 'touch'
  else
    return null

# Returns x/y of mouse or touch irrespective of event type
window.getPointer = (event) ->
  # If event.type contains 'mouse'
  # console.log event
  if pointerType(event) is 'mouse'
    { x: event.clientX, y: event.clientY }
  # If event.type contains 'touch'
  else if pointerType(event) is 'touch'
    { x: event.originalEvent.touches[0].clientX, y: event.originalEvent.touches[0].clientY }
  else
    throw 'Invalid event'
    null

window.styleUtilities =
  transformOrigin: ($elements, x, y) ->
    $elements.css
      transformOrigin:        "#{x} #{y}"
      webkitTransformOrigin:  "#{x} #{y}"
      mozTransformOrigin:     "#{x} #{y}"
      msTransformOrigin:      "#{x} #{y}"

validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test(email)

$.fn.hasScrollBar = () ->
  @get(0).scrollHeight > @get(0).clientHeight


class window.DomCoolTest
  constructor: (@onCool, @t) ->
    @timer = null

  warm : () =>
    if @timer?
      clearTimeout @timer
      @timer = null
    @timer = setTimeout (()=>
      @timer = null
      @onCool()
    ), @t

  isWarm : () -> @timer?
