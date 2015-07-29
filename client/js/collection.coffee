
placeHolder_under_mouse = (event) ->
  collection = $(@)
  element = collection_children.call(@).first()
  # Get the element that the mouse is over
  while mouse.x > (parseInt(element.css('x')) + element.width())
    element = element.next()

  if mouse.x < parseInt(element.css('x'))+ element.width()/2
    collection_insert_before.call @, drag_placeholder, element
  else 
    collection_insert_after.call @, drag_placeholder, element
  true

scroll_collection_by_delta = (collection, delta) -> 
  children = collection_children.call collection
  scroll_position = collection.data('scroll_position') + delta

  scroll_position = Math.min scroll_position, $(window).width()/2 - children.first().width()/2
  scroll_position = Math.max scroll_position, -collection.data('maxX') + $(window).width()/2 + children.last().width()/2

  collection.data 'scroll_position', scroll_position
  children.each element_place

collection_close = () ->
  collection = $('.collection.open')
  history.pushState {name: "home"}, "", "/"
  
  $('.collection').show()
  $('.translate-container').css { x: 0, y: old_top }
  $('.scale-container').css { scale: 1/scaleMultiple }
  window.scale = 1/scaleMultiple
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
  window.scale = 1
  $('.translate-container').css {x: 0, y: offsetTop, queue: false}

  collection_init.call collection

collection_scroll_wheel = (event) ->
  collection = $(@)
  event.preventDefault()
  return unless collection.hasClass 'open'
  delta = if event.deltaX is 0 then -event.deltaY else -event.deltaX
  scroll_collection_by_delta(collection, delta)

collection_children = () ->
  $(@).children('.elements').children()

# call once the dom inside the collection changes and positions need to be 
# recalculated
collection_realign_elements = () ->
  collection = $(@)
  lastX = 0
  maxX = -Infinity
  children = collection_children.call @
  zIndex = children.length
  children.each () ->
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
    collection_realign_elements.call a.parent().parent()
  else
    collection_realign_elements.call a.parent().parent()
    collection_realign_elements.call b.parent().parent()

collection_insert_after = (a, b) ->
  collection = $(@)
  a.insertAfter b
  if a.parent() is b.parent()
    collection_realign_elements.call a.parent().parent()
  else
    collection_realign_elements.call a.parent().parent()
    collection_realign_elements.call b.parent().parent()