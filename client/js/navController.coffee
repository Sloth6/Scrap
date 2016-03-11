$ ->
  initNav $(constants.dom.nav)

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
          duration: 500
          easing: constants.velocity.easing.smooth

retractNav = ->
  $sections = $(constants.dom.nav).children('section')
  unless $(constants.dom.collectionsMenu).hasClass('open') or $(window).scrollTop() < 10
    $sections.each ->
      $(@).velocity('stop', true).velocity
        properties:
          translateY: if $(@).hasClass('center') then -$(@).find('.headerButton').height() / 1.75 else -$(@).height()
        options:
          duration: 500
          easing: constants.velocity.easing.smooth

extendNav = ->
  $sections = $(constants.dom.nav).children('section')
  $sections.velocity('stop', true).velocity
    properties:
      translateY: 0
    options:
      duration: 500
      easing: constants.velocity.easing.smooth

initNav = ($nav) ->
  $nav.hover extendNav, retractNav
#   popController.init $('.left .headerButton, .right .headerButton a')
  $nav.find('a').mouseenter ->
    # Hide special cursor
    cursorView.end()
