detail_view_scale = 1.0
scaleMultiple = 4 # must be the same as in _container.scss
old_top = 0
mouse = { x: null, y: null }
margin = -0.5
scale = 1/scaleMultiple
click = { x: 0, y: 0 }
Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

master_scroll = (event) ->
  return if $('.open').length
  event.preventDefault()
  y = parseInt($('.translate-container').css('y')) + event.deltaY
  y = Math.min y, 0
  y = Math.max y, -collection_max_y/scaleMultiple
#   y += 109
  $('.translate-container').css { y }

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
  window.socket = io.connect()
  window.drag_placeholder = $('<div>').
    css({ width: 200, height: 200, 'border-width':2, 'border-style':'solid', position:'absolute' }).
    addClass('placeHolder')

  history.pushState { name: "home" }, "", "/"  
  
  # $('.element').draggable draggableOptions
  # $('.elements').css({ transformOrigin: 'top left' })
  
  editable = document.getElementById('editable');

  editable = $('.editable')
  editable.on 'blur', () ->
    #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
    $('<div contenteditable="true"></div>').appendTo('body').focus().remove()
    
  $('.collection').each collection_init
  

  $(window).on 'mousewheel', master_scroll
  $(window).scroll () ->
    $('.collection.open .element').each element_place
    
  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX / scale
    mouse.y = event.clientY / scale

  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    collection_close() if page is 'home'
        