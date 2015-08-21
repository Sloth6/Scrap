mouse = { x: null, y: null }
click = { x: null, y: null }

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  
  card_container.init.call $('.cardContainer')
  
  width = card_container.children.call($('.collections')).length * 400
  $(document.body).css { width }

  $(window).scroll () ->
    card_container.scroll.call $('.cardContainer.open')

  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()
    
  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY

  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    collection_close() if page is 'home'
        