detail_view_scale = 1.0
scaleMultiple = 2 # must be the same as in _container.scss
old_top = 0
mouse = { x: null, y: null }
margin = -0.5
scale = 1/scaleMultiple
click = { x: 0, y: 0 }
Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

logistic = (x) ->
  1/(1 + Math.pow(Math.E, -x))

element_place = () ->
  element = $(@)
  border = 300

  return if element.hasClass('dragging')
  offset = element.data 'scroll_offset'
  collection_scroll = element.parent().data 'scroll_position'
  maxX = ($(window).width()  / scale )- element.width()

  x = offset + collection_scroll + margin

  start = ($(window).width() - border)

  left_min = -element.width()
  left_start = left_min + border

  if x > start
    percent = (x - start) / border
    x = start + (logistic(percent)-0.5)*2 * border
  else if x < left_start
    percent = 1 - ((x - left_min)/ border)
    x =  left_start - ((logistic(percent)-0.5)*2 * border)
  # x = Math.max x, 0
  # x = Math.min x, maxX

  element.css { x, y:0 }

element_move = (x, delta = false) ->
  element = $(@)
  offset = element.data 'scroll_offset'
  element.data 'scroll_offset', offset + x
  element_place.call @

scroll_collection_by_delta = (collection, delta) ->  
  scroll_position = collection.data('scroll_position') + delta

  scroll_position = Math.min scroll_position, $(window).width()/2 - collection.children().first().width()/2
  scroll_position = Math.max scroll_position, -collection.data('maxX') + $(window).width()/2 + collection.children().last().width()/2

  collection.data 'scroll_position', scroll_position
  collection.children().each element_place

collection_close = () ->
  collection = $('.collection.open')
  history.pushState {name: "home"}, "", "/"
  
  $('.collection').show()
  $('.translate-container').css { x: 0, y: old_top }
  $('.scale-container').css { scale: 1/scaleMultiple }
  scale = 1/scaleMultiple
  collection.addClass('closed').removeClass 'open'

  collection_init.call collection

collection_enter = (event) ->
  collection = $(@)
  return if collection.hasClass 'open'
  
  history.pushState {name: "derp"}, "", "/"
  collection.addClass('open').removeClass 'closed'
  
  old_top = $('.translate-container').css 'y'

  $('.collection').not(@).hide()
  $('.collection').not(@).addClass 'closed'
  offsetTop = -(collection.position().top*scaleMultiple) + $(window).height()/2 - collection.height()/2
  
  $('.scale-container').css { scale: 1, queue: false }
  scale = 1
  $('.translate-container').css {x: 0, y: offsetTop, queue: false}

  collection_init.call collection

collection_scroll_wheel = (event) ->
  collection = $(@)
  event.preventDefault()
  return unless collection.hasClass 'open'
  delta = if event.deltaX is 0 then -event.deltaY else -event.deltaX
  scroll_collection_by_delta(collection, delta)

# call once the dom inside the collection changes and positions need to be 
# recalculated
collection_realign_elements = () ->
  collection = $(@)
  lastX = 0
  maxX = -Infinity
  zIndex = collection.children().length
  collection.children().each () ->
    if not $(@).hasClass 'dragging'
      $(@).data 'scroll_offset', lastX
      $(@).css {zIndex: zIndex--}
      element_place.call @
      lastX += $(@).width() + margin
      maxX = lastX

  $(@).data { maxX }

collection_init = () ->
  # $(@).children(":not(:first)").remove();
  $(@).data 'scroll_position', 0
  collection_realign_elements.call @

# put element a before b
collection_insert_before = (a, b) ->
  collection = $(@)
  a.insertBefore b
  if a.parent() is b.parent()
    collection_realign_elements.call a.parent()
  else
    collection_realign_elements.call a.parent()
    collection_realign_elements.call b.parent()

collection_insert_after = (a, b) ->
  collection = $(@)
  a.insertAfter b
  if a.parent() is b.parent()
    collection_realign_elements.call a.parent()
  else
    collection_realign_elements.call a.parent()
    collection_realign_elements.call b.parent()

master_scroll = (event) ->
  return if $('.open').length
  event.preventDefault()
  y = parseInt($('.translate-container').css('y')) + event.deltaY
  y = Math.min y, 0
  y = Math.max y, -collection_max_y/scaleMultiple
  $('.translate-container').css { y }

placeHolder_under_mouse = (event) ->
  collection = $(@)
  
  element = collection.children().first()

  # Get the element that the mouse is over
  while mouse.x > (parseInt(element.css('x')) + element.width())
    element = element.next()

  # console.log mouse.x, parseInt(element.css('x'))+element.width()
  if mouse.x < parseInt(element.css('x'))+ element.width()/2
    collection_insert_before.call @, drag_placeholder, element
  else 
    collection_insert_after.call @, drag_placeholder, element
  
  # window.foo and window.foo.css {scale:1.0}
  # element.css {scale:0.5}
  # window.foo = element
  # 
  return

$ ->
  border = $(window).width()/3
  min_speed = 0
  max_speed = 120
  fun = ()  ->
    return unless $('.dragging').length
    if mouse.x <= border
      speed = ((border - mouse.x) / border) * (max_speed - min_speed) + min_speed
      collection = $('.collection.open')
      scroll_collection_by_delta collection, speed if collection
    else if mouse.x >= $(window).width() - border
      speed = ((mouse.x - $(window).width() + border) / border) * (max_speed - min_speed) + min_speed
      collection = $('.collection.open')
      scroll_collection_by_delta collection, -speed if collection
  setInterval fun, 25

draggableOptions =
  start: (event) ->
    click.x = event.clientX
    click.y = event.clientY

    $(@).addClass 'dragging'
    drag_placeholder.css { width: $(@).width() }
    collection_insert_before.call $(@).parent(), drag_placeholder, $(@)
    
    $(@).css {x:0, y: 0}
    $(@).parent().on 'mousemove', placeHolder_under_mouse

  drag: (event, ui) ->
    original = ui.originalPosition
    ui.position = {
      left: (event.clientX - click.x + original.left) / scale
      top:  (event.clientY - click.y + original.top) / scale
    }
  stop: (event, ui) ->
    element = $(@)
    $(@).parent().off 'mousemove', placeHolder_under_mouse
    element.removeClass 'dragging'
    element.css {left:'auto', top:'auto'}

    collection_insert_before.call element.parent(), element, drag_placeholder
    drag_placeholder.remove()    
    collection_realign_elements.call element.parent()
$ ->

  window.drag_placeholder = $('<div>').
    css({ width: 200, height: 200, 'border-width':2, 'border-style':'solid', position:'absolute' }).
    addClass('placeHolder')

  history.pushState { name: "home" }, "", "/"  
  
  $('.element').draggable draggableOptions

  $('.collection').click collection_enter  
  $('.collection').each collection_init
  $('.collection').on 'mousewheel', collection_scroll_wheel
  
  $('.collection').on 'mousemove', (event) ->
    mouse.x = event.clientX / scale
    mouse.y = event.clientY / scale

  $(window).on 'mousewheel', master_scroll
  
  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    collection_close() if page is 'home'
        