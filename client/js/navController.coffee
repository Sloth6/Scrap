$ ->
  initNav $(constants.dom.nav)
  initAddCollectionForm $('#newCollectionForm')
  
# window.nav =
#   init: ->
#   hide: ->
  
hideNav = ->
  $sections = $(constants.dom.nav).children()
  unless $(constants.dom.collectionsMenu).hasClass('open')
    $sections.each ->
      $(@).velocity('stop', true).velocity
        properties:
          translateY: -$(@).height()*1.5
        options:
          duration: 1000
          easing: constants.velocity.easing.smooth
          
retractNav = ->
  $sections = $(constants.dom.nav).children('section')
  unless $(constants.dom.collectionsMenu).hasClass('open') or $(window).scrollTop() < 10
    $sections.each ->
      translateY = if $(@).hasClass('center') then -$(@).height()*1.5 / 2 else -$(@).height()*1.5
      $(@).velocity('stop', true).velocity
        properties:
          translateY: translateY
        options:
          duration: 1000
          easing: constants.velocity.easing.smooth

extendNav = ->
  $sections = $(constants.dom.nav).children('section')
  $sections.velocity('stop', true).velocity
    properties:
      translateY: 0
    options:
      duration: 1000
      easing: constants.velocity.easing.smooth
  
initNav = ($nav) ->
  $nav.hover extendNav, retractNav
  parallaxHover $('.left .headerButton, .right .headerButton a')
  $nav.find('a').mouseenter ->
    # Hide special cursor
    cursorView.end()
  
initAddCollectionForm = ($form) ->
  $form.submit (event) ->
    name = $('#newCollectionForm [type=text]').val()
    $('#newCollectionForm [type=text]').val ''
    socket.emit 'addCollection', { name }
    event.preventDefault()