
  
window.constants =
  velocity:
    easing:
      smooth: [20, 10]
      spring: [50, 10]
    duration: 1000
    
launch = ($header, $collections) ->
  $header.hide()
  $collections.hide()
  $header.velocity
    properties:
      translateY: [0, -$header.height()]
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      begin: -> $header.show()
  $collections.each ->
    $(@).velocity
      properties:
        translateY: [$(window).height() - $(@).height() * 1.5, $(window).height()]
      options:
        duration: constants.velocity.duration
        easing: constants.velocity.easing.smooth
        begin: -> $(@).show()

slideInLabels = ($header, $collections) ->
  $collections.each ->
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
      complete: -> $header.hide()
      
removeFrame = -> parent.window.postMessage("removetheiframe", "*")
      
close = ($header, $menu, $collections) ->
  $header.velocity
    properties:
      translateY: -$header.height()
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: -> $header.hide()
  $collections.each ->
    $(@).velocity
      properties:
        translateY: $(window).height()
      options:
        duration: constants.velocity.duration
        easing: constants.velocity.easing.smooth
        complete: ->
          $(@).hide()
          removeFrame() if $(@).index() is $collections.length - 1 # last collection

addCollection = ($collection) ->
  # collectionKey = $collection.data 'collectionkey'
  # todo, post to server
  removeFrame()
  
$ ->
  $header = $('h1')
  $menu = $('ul.collectionsMenu')
  $collections = $menu.find('li')
  
  launch $header, $collections
  
  $collections.first().mouseenter -> slideInLabels $header, $collections
  
  $collections.each ->
    $collection = $(@)
    $collection.find('a').click (event) ->
      event.stopPropagation()
      addCollection $collection
      
  $('body').click -> close($header, $menu, $collections)
  setTimeout ->
    close($header, $menu, $collections)
  , 2000
