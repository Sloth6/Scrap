scale = 0.5
margin = -0.5
old_scroll = $(window).scrollTop()


collection_place = (scroll_delta) ->
  logistic = (x) ->
    1/(1 + Math.pow(Math.E, -x*.2))

  collection = $(@)
  border = 250

  y =  - $(window).scrollTop() + collection.data('offset')
  start = $(window).height() - border
  top_min = -collection.height()
  top_start = top_min + border



  if y > start
    percent = (y - start) / border
    y = start + (logistic(percent)-0.5)*2 * border
  else if y < top_start
    percent = 1 - ((y - top_min)/ border)
    y =  top_start - ((logistic(percent)-0.5)*2 * border)
  else
    scroll_collection_by_delta $(@), -scroll_delta
  collection.css { x:0 , y }

$ ->
  # $('.collection')
  # $( '.collection:not(:first)' ).remove();
  # window.resizeTo($(window).width(),10000)
  $(document.body).css height: 5000
  $('.collection').each () -> 
    collection_init.call $(@)
    collection_place.call $(@)
  
  $(window).scroll (event) ->
    scroll_delta = $(window).scrollTop() - old_scroll
    old_scroll = $(window).scrollTop()
    $('.collection').each () ->
      collection_place.call @, scroll_delta
