detail_view_scale = 1.0

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array


close_detail_view = () ->
  history.pushState {name: "home"}, "", "/"
  # $('.open').children().transition { x: 0 }, 300, 'linear'
  $('.collection').show()
  $('.content').css {x: 0, y: 0, queue: false }
  $('.content').css { scale: 1/4, queue: false }
  $('.open').removeClass 'open'

enter_detail_view = (event) ->
  return if $(@).hasClass 'open'
  $(@).addClass 'open'
  # $(@).children().css { x: 0 }
  history.pushState {name: "derp"}, "", "/"

  $('.collection').not(@).hide()
  offsetTop = -($(@).position().top*4) + $(window).height()/2 - $(@).height()/2
  $('.content').css { scale: 1}, 1000, 'linear'
  $('.content').css {x: 0, y: offsetTop, queue: false }
  
scroll_collection = (event) ->
  return unless $(@).hasClass 'open'
  event.preventDefault()
  delta = if event.deltaX is 0 then -event.deltaY else -event.deltaX
  $(@).children().css { x: "+=#{delta}px" }, 0, 'linear'

$ ->
  history.pushState {name: "home"}, "", "/"

  $('.collection').on 'mousewheel', scroll_collection
  $('.collection').click enter_detail_view  
 
  $('.collection').each () ->
    collection = $(@)
    lastX = 0
    collection.children().each () ->
      # console.log @, $(@).width()
      margin = 5
      $(@).css {x: lastX}
      # console.log @, lastX
      lastX += $(@).width() + margin

      # console.log $(@).position().left,$(@).position().left + $(@).width() 
    # $('img').map(function() { return $(this).width(); }).get()

  window.onpopstate = (event) ->
    return unless event.state?
    page = event.state.name
    close_detail_view() if page is 'home'
        