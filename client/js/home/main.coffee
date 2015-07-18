detail_view_scale = 1.0
scaleMultiple = 2 # must be the same as in _container.scss
old_top = 0



Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

collection_close = () ->
  history.pushState {name: "home"}, "", "/"
  collection_reset.call $('.collection.open')
  $('.collection').show()
  $('.translate-container').css { x: 0, y: old_top }
  $('.scale-container').css { scale: 1/scaleMultiple }
  $('.collection.open').addClass('closed').removeClass 'open'

collection_enter = (event) ->
  collection = $(@)
  return if collection.hasClass 'open'
  
  history.pushState {name: "derp"}, "", "/"
  collection.addClass('open').removeClass 'closed'
  collection_reset.call collection
  old_top = $('.translate-container').css 'y'

  $('.collection').not(@).hide()
  $('.collection').not(@).addClass 'closed'
  offsetTop = -(collection.position().top*scaleMultiple) + $(window).height()/2 - collection.height()/2
  $('.scale-container').css { scale: 1, queue: false }
  $('.translate-container').css {x: 0, y: offsetTop, queue: false }
  
collection_scroll = (event) ->
  collection = $(@)
  return unless collection.hasClass 'open'
  event.preventDefault()
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
    margin = -2
    $(@).css { x: lastX }
    $(@).data 'scroll_offset', lastX
    lastX += $(@).width() + margin
    maxX = lastX
  $(@).data { maxX }

master_scroll = (event) ->
  return if $('.open').length
  event.preventDefault()
  # y_max = (collection_max_y/scaleMultiple), y
  y = parseInt($('.translate-container').css('y')) + event.deltaY
  y = Math.min y, 0
  y = Math.max y, -collection_max_y/scaleMultiple
  $('.translate-container').css { y }

$ ->
  # $('.collection').css({'background-color':'blue'})
  history.pushState {name: "home"}, "", "/"  
  
  $('.collection').click collection_enter  
  $('.collection').each collection_reset
  $('.collection').on 'mousewheel', collection_scroll

  $(window).on 'mousewheel', master_scroll

  # $( window ).resize collection_reset

  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    collection_close() if page is 'home'
        