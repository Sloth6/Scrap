window.constants =
  style:
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
  velocity:
    easing:
      smooth: [20, 10]
      spring: [50, 10]
    duration: 1000
    
    
fancyHover = ($elements) ->
  getProgressValues = ($element, scale) ->
    offsetX = $element.offset().left - $(window).scrollLeft()
    offsetY = $element.offset().top  - $(window).scrollTop()
    progressY = Math.max(0, Math.min(1, (event.clientY - offsetY) / ($element.height() * scale)))
    progressX = Math.max(0, Math.min(1, (event.clientX - offsetX) / ($element.width()  * scale)))      
    { x: progressX, y: progressY }
  getRotateValues = ($element, progress) ->
    maxRotateY = if $element.is('a') then 22 else 22
    maxRotateX = if $element.is('a') then 22 else 22
    rotateX = maxRotateY * (progress.y - .5)
    rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
    { x: rotateX, y: rotateY}
  $elements.each ->
    $element = $(@)
    $parent = $element.parent()
    scale = 1.25
    perspective = 100
    duration = 250
    $element.mouseenter (event) ->
      progress = getProgressValues($element, scale)
      rotate = getRotateValues($element, progress)
      $element.transition
        scale: scale
        easing: constants.style.easing
        duration: duration
      $element.css
        perspective: perspective
      $parent.css
        zIndex: 2
    $element.mousemove (event) ->
      progress = getProgressValues($element, scale)
      rotate = getRotateValues($element, progress)
      $element.css
        scale: scale
        z: 250
        rotateX: "#{rotate.x}deg"
        rotateY: "#{rotate.y}deg"
    $element.mouseleave ->
      $element.css
        zIndex: 0
      $element.parents('.contents').css
        zIndex: 0
      $element.transition
        scale: 1
        rotateX: 0
        rotateY: 0
        easing: constants.style.easing
        duration: duration
    
launch = ($header, $collections) ->
  $header.hide()
  $collections.css('opacity', 0).hide()
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
        opacity: [1, 1]
      options:
        delay: 31.25 * $(@).index()
        duration: constants.velocity.duration
        easing: constants.velocity.easing.smooth
        begin: -> $(@).show()

slideInLabels = ($header, $menu, $collections) ->
  $menu.data 'open', true
  $collections.each ->
    $(@).velocity
      properties:
        translateY: 0
      options:
        delay: 31.25 * $(@).index()
        duration: constants.velocity.duration
        easing: constants.velocity.easing.smooth
  $header.velocity
    properties:
      translateY: -$header.height()
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: -> $header.hide()
  $('.container').velocity
    properties:
      backgroundColor: '#ffffff'
      backgroundColorAlpha: [0.9, 0]
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      
removeFrame = ->
  parent.window.postMessage("removetheiframe", "*")
  console.log 'remove'
      
close = ($header, $menu, $collections) ->
  $chosen = $collections.filter('.chosen')
  $header.velocity
    properties:
      translateY: -$header.height()
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: -> $header.hide()
  $collections.not('.chosen').each ->
    $(@).velocity
      properties:
        translateY: $(window).height()
      options:
        delay: 31.25 * (($collections.length - 1) - $(@).index())
        duration: constants.velocity.duration/1.5
        easing: constants.velocity.easing.smooth
        complete: ->
          unless $chosen.length > 0
            $(@).hide()
            removeFrame() if $(@).index() is $collections.length - 1 # last collection
  $chosen.find('.contents').velocity
    properties:
      translateY: -$chosen.offset().top
    options:
      delay: 0
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: ->
        $chosen.find('.contents').velocity
          properties:
            translateY: -$chosen.offset().top-$chosen.height()*1.5
          options:
            delay: 500
            duration: constants.velocity.duration
            easing: constants.velocity.easing.smooth
            complete: ->
              $collections.hide()
              removeFrame()
  $chosen.find('a').transition
    scale: 1
    rotateX: 0
    rotateY: 0
    easing: constants.style.easing
    duration: constants.velocity.duration
  $('.container').velocity
    properties:
      backgroundColorAlpha: 0
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
              

addCollection = ($collection) ->
  $collection.addClass('chosen')
#   	collectionKey = $collection.data 'collectionkey'
#   	console.log "addCollection #{collectionKey} to #{articleId}"
#   	host = document.location.host
#   	$.post("http://localhost:9001/addArticleCollection", { articleId, collectionKey }).
#   		fail(() -> console.log 'Failed to addCollection').
#   		always close
#   removeFrame()
  
$ ->
  $header = $('h1')
  $menu = $('ul.collectionsMenu')
  $collections = $menu.find('li')
  
  fancyHover $collections.not(':first-of-type').find('a')
  
  launch $header, $collections
  
#   rotateColor = ($element, hue)->
#     $element.css '-webkit-text-fill-color', "hsl(#{hue},100%,75%)"
#     
#   $header.add($collections.first().find('a')).each ->
#     hue = Math.floor(Math.random() * 360)
#     $a = $(@)
#     rotateColor $a, hue
#     setInterval ->
#       hue += 30
#     , 1000
  
  $collections.first().mouseenter -> slideInLabels $header, $menu, $collections
  
  $collections.each ->
    $collection = $(@)
    $collection.find('a').click (event) ->
      event.stopPropagation()
      addCollection $collection
      close($header, $menu, $collections)
      
  $('body').click -> close($header, $menu, $collections)
#   setTimeout ->
#     close($header, $menu, $collections) unless $menu.data('open')
#   , 2000

