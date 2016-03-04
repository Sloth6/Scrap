Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

Array.prototype.last = () -> @[@length - 1]

window.xTransform = ($element) ->
#   transform = $element.css('transform')
#   new WebKitCSSMatrix(transform).e
  parseFloat $.Velocity.hook($element, 'translateX')

window.yTransform = ($element) ->
#   transform = $element.css('transform')
#   new WebKitCSSMatrix(transform).f
  parseFloat $.Velocity.hook($element, 'translateY')

window.getRotateZ = ($element) ->
  parseFloat $.Velocity.hook($element, 'rotateZ')

window.logisticFunction = (x) ->
  1 / (1 + Math.pow(Math.E, -x))
  
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
