window.onScroll = () ->
  scrollTop = $(window).scrollTop()
  
  # detect direction change
  if window.oldScrollTop isnt scrollTop
    if window.oldScrollTop < scrollTop
      if window.scrollDirection isnt 'down'
        events.onChangeScrollDirection 'down'
    else
      if scrollDirection isnt 'up'
        events.onChangeScrollDirection 'up'
    window.oldScrollTop = scrollTop
  if scrollTop <= 10
    extendNav() unless $('nav').children().hasClass('velocity-animating')
  else
    unless window.scrollDirection is 'up'
      retractNav() unless $('nav').children().hasClass('velocity-animating')
      
window.onChangeScrollDirection = (direction) ->
  window.scrollDirection = direction
  if $(window).scrollTop() > 10
    if direction is 'up'
      extendNav()
    else
      retractNav()

$ ->
  window.oldScrollTop     = 0
  window.scrollDirection  = 'down'
  
  $(window).scroll -> onScroll()
  onScroll()