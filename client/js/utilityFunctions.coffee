Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

Array.prototype.last = () -> @[@length - 1]

window.xOfSelf = () -> xTransform $(@)

window.yOfSelf = () -> yTransform $(@)

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

validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test(email)

$.fn.hasScrollBar = () ->
  @get(0).scrollHeight > @get(0).clientHeight
