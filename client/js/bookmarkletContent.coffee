close = () ->
  parent.window.postMessage("removetheiframe", "*")

addCollection = ($collection) ->
  collectionKey = $collection.data 'collectionkey'
  # todo, post to server
  close()
  
window.constants =
  velocity:
    easing:
      smooth: [20, 10]
      spring: [50, 10]
    duration: 500

$ ->
  $header = $('h1')
  $menu = $('ul.collectionsMenu')
  $labels = $menu.find('li')
  
  $header.velocity
    properties:
      translateY: [0, -$header.height()]
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth

  $labels.each ->
    $(@).velocity
      properties:
        translateY: [$(window).height() - $menu.find('li').height() * 1.5, $(window).height()]
      options:
        duration: constants.velocity.duration
        easing: constants.velocity.easing.smooth

  $labels.first().mouseenter ->
    $labels.each ->
      $(@).velocity
        properties:
          translateY: 0
        options:
          duration: constants.velocity.duration
          easing: constants.velocity.easing.smooth
    $header.velocity
      properties:
        translateY: -$header.height()
      options:
        duration: constants.velocity.duration
        easing: constants.velocity.easing.smooth
  
  
  $labels.click () ->
    console.log 'alldone!'
    addCollection($(@))
