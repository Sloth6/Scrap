detail_view_scale = 1.0

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array


collection_close = () ->
  history.pushState {name: "home"}, "", "/"
  # $('.open').children().transition { x: 0 }, 300, 'linear'
  collection_reset.call $('.collection.open')
  $('.collection').show()
  $('.content').css {x: 0, y: 0, queue: false }
  $('.content').css { scale: 1/4, queue: false }
  $('.open').removeClass 'open'

collection_enter = (event) ->
  collection = $(@)
  return if collection.hasClass 'open'
  collection.addClass 'open'
  collection_reset.call collection
  history.pushState {name: "derp"}, "", "/"
  $(window).scrollTop(0)
  $('.collection').not(@).hide()
  offsetTop = -(collection.position().top*4) + $(window).height()/2 - collection.height()/2
  $('.content').css { scale: 1}, 1000, 'linear'
  $('.content').css {x: 0, y: offsetTop, queue: false }
  
collection_scroll = (event) ->
  collection = $(@)
  event.preventDefault()
  return unless collection.hasClass 'open'
  margin = -0.5
  delta = if event.deltaX is 0 then -event.deltaY else -event.deltaX
  scroll_position = collection.data('scroll_position') + delta
  scroll_position = Math.max -collection.data('maxX'), scroll_position
  scroll_position = Math.min scroll_position, $(window).width()# + collection.data('maxX')
  collection.data 'scroll_position', scroll_position

  # zIndex_left = 0
  zIndex_right = collection.children().length
  i = 0
  collection.children().each () ->
    x = $(@).data('scroll_offset') + scroll_position + margin
    x = Math.max x, 0
    x = Math.min x, $(window).width() - $(@).width()
    zIndex = if x+$(@).width()/2 < $(window).width() /2 then i else collection.children().length - i
    $(@).css { x , zIndex}
    i++

collection_reset = () ->
  collection = $(@)
  lastX = 0
  maxX = -Infinity
  collection.data('scroll_position', 0)
  z = 0
  collection.children().each () ->
    # console.log $(@).width() if $(@).hasClass('soundcloud')
    margin = 5
    $(@).css { x: lastX }
    $(@).data 'scroll_offset', lastX
    lastX += $(@).width() + margin
    maxX = lastX
  $(@).data { maxX }

$ ->
  history.pushState {name: "home"}, "", "/"  
  $('.collection').click collection_enter  
  $('.collection').each collection_reset
  $('.collection').on 'mousewheel', collection_scroll

  # $( window ).resize collection_reset

  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    collection_close() if page is 'home'
        