detail_view_scale = 1.0

close_detail_view = () ->
  history.pushState {name: "home"}, "", "/"

  $('.open').children().transition { x: 0 }, 300, 'linear'
  $('.content').css {x: 0, y: 0, queue: false }
  # $('.collection').show()
  $('.content').transition { scale: 1/4, queue: false }, 300, 'linear', () ->
    $('.open').removeClass 'open'


enter_detail_view = (elem, event) ->
  elem.addClass 'open'
  elem.children().css { x: 0 }
  # $('.collection').not(elem[0]).hide()
  offsetTop = -(elem.position().top*4) + $(window).height()/2 - elem.height()/2
  $('.content').transition { scale: 1, queue: false }, 300, 'linear'
  $('.content').css {x: 0, y: offsetTop, queue: false }
  history.pushState {name: "derp"}, "", "/"

$ ->
  history.pushState {name: "home"}, "", "/"

  $('.collection').on 'mousewheel', (event) ->
    # console.log event.deltaX, event.deltaY
    event.preventDefault()

    delta = if event.deltaX is 0 then -event.deltaY else -event.deltaX
    $(@).children().css { x: "+=#{delta}px" }, 0, 'linear'
    # $(@).animate( { top: "+=#{deltaY}", left: "+=#{deltaX}" }, 0, 'linear' )

  $('.collection').click (event) ->
    enter_detail_view $(@), event

 
  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    close_detail_view() if page is 'home'
        