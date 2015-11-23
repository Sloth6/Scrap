Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

Array.prototype.last = () -> @[@length - 1]

window.xOfSelf = () -> xTransform $(@)

window.yOfSelf = () -> yTransform $(@)

window.xTransform = (elem) ->
  transform = elem.css('transform')
  new WebKitCSSMatrix(transform).e

window.yTransform = (elem) ->
  transform = elem.css('transform')
  new WebKitCSSMatrix(transform).f

window.logisticFunction = (x) ->
  1 / (1 + Math.pow(Math.E, -x))

validateEmail = (email) ->
  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
  re.test(email)
